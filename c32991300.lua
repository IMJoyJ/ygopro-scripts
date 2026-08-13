--刻まれし魔の神聖棺
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只以上
-- ①：自己·对方回合1次，以连接怪兽以外的自己墓地1只恶魔族·光属性怪兽为对象才能发动。那只怪兽特殊召唤，自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只怪兽装备。
-- ●装备怪兽的攻击力上升给自身装备的连接怪兽的连接标记合计×600。
-- ●装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 初始化该卡的效果：注册连接召唤手续（2~3只素材，其中至少1只光属性·恶魔族的连接怪兽），并注册①效果——自己·对方回合1次，以连接怪兽以外的自己墓地1只恶魔族·光属性怪兽为对象才能发动，将其特殊召唤并把这张卡当作装备卡装备给那只怪兽。
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求用2~3只怪兽作为素材，且素材中至少包含1只光属性·恶魔族的连接怪兽（由lcheck检查）。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，以连接怪兽以外的自己墓地1只恶魔族·光属性怪兽为对象才能发动。那只怪兽特殊召唤，自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 连接素材检查函数：判定作为连接素材的怪兽组中是否存在至少1只满足s.lmfilter的怪兽。
function s.lcheck(g,lc)
	return g:IsExists(s.lmfilter,1,nil)
end
-- 素材过滤函数：判定怪兽是否为光属性·恶魔族的连接怪兽。
function s.lmfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_LIGHT) and c:IsLinkRace(RACE_FIEND)
end
-- 对象过滤函数：筛选自己墓地中满足光属性、恶魔族、不是连接怪兽且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and not c:IsType(TYPE_LINK)
end
-- 效果发动条件与取对象处理：先验证连锁处理中选定的对象合法（在墓地、属于自己且满足spfilter）；在发动时检查自己魔陷区与怪兽区均有空位，并且墓地存在符合条件的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：必须自己魔陷区有空位（用于放置装备后的这张卡）且怪兽区有空位（用于特殊召唤对象怪兽）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件补充：同时墓地存在至少1只满足spfilter的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出选择提示信息，提示需要选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter的非连接恶魔族·光属性怪兽作为效果对象，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁处理包含1只怪兽的特殊召唤（对象为g）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本连锁处理包含装备动作，装备卡为效果发动者自身（这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将对象怪兽表侧特殊召唤；若特殊召唤成功且这张卡仍在自己场上并为自己控制，则把这张卡当作装备卡装备给那只怪兽，并注册装备限制、攻击力上升、贯穿伤害三个效果；若魔陷区无空位或对象怪兽不在怪兽区，则将这张卡送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理中锁定的对象怪兽（之前选择的目标）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽仍与效果关联且不受王家长眠之谷影响，然后以表侧表示将其特殊召唤；若特殊召唤成功（返回值不为0）才继续后续处理。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 检查装备前提：若自己魔陷区没有空位，或对象怪兽不在怪兽区，则无法继续装备。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc:IsLocation(LOCATION_MZONE) then
			-- 因无法装备而将这张卡本身以效果原因送去墓地。
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试把这张卡作为装备卡装备给对象怪兽；若装备失败则终止后续处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ●装备怪兽的攻击力上升给自身装备的连接怪兽的连接标记合计×600。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(s.value)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- ●装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
-- 装备限制函数：这张装备卡仅能装备给e:GetLabelObject()所记录的那只被特殊召唤的怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击力上升值计算：取得装备怪兽及其装备的全部卡，将其中所有装备卡的连接标记合计乘以600，作为攻击力上升数值。
function s.value(e,c)
	local tc=e:GetHandler():GetEquipTarget()
	local g=tc:GetEquipGroup()
	return g:GetSum(Card.GetLink)*600
end
