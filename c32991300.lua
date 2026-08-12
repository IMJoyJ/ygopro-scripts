--刻まれし魔の神聖棺
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只以上
-- ①：自己·对方回合1次，以连接怪兽以外的自己墓地1只恶魔族·光属性怪兽为对象才能发动。那只怪兽特殊召唤，自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只怪兽装备。
-- ●装备怪兽的攻击力上升给自身装备的连接怪兽的连接标记合计×600。
-- ●装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续、启用复活限制并注册诱发效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用2到3只满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- 效果描述：选择1只恶魔族·光属性怪兽特殊召唤，自己场上的这张卡当作装备魔法卡使用给那只怪兽装备
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
-- 连接怪兽过滤函数，判断是否存在满足条件的连接怪兽
function s.lcheck(g,lc)
	return g:IsExists(s.lmfilter,1,nil)
end
-- 连接怪兽属性与种族过滤函数，判断是否为光属性恶魔族怪兽
function s.lmfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_LIGHT) and c:IsLinkRace(RACE_FIEND)
end
-- 特殊召唤过滤函数，判断是否为光属性恶魔族怪兽且可特殊召唤且非连接怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and not c:IsType(TYPE_LINK)
end
-- 效果的发动条件判断，检查是否有满足条件的目标怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的魔法陷阱区域和怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，确定装备的卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤和装备操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且可特殊召唤，且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 判断装备区域是否足够或目标怪兽是否仍在场上
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc:IsLocation(LOCATION_MZONE) then
			-- 将自身送入墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试将自身装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制效果，确保只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备怪兽攻击力上升效果，上升值为装备的连接怪兽连接标记合计×600
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(s.value)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 设置装备怪兽攻击时无视守备力的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
-- 装备限制函数，确保只能装备给指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击力上升值计算函数，根据装备的连接怪兽连接标记合计计算
function s.value(e,c)
	local tc=e:GetHandler():GetEquipTarget()
	local g=tc:GetEquipGroup()
	return g:GetSum(Card.GetLink)*600
end
