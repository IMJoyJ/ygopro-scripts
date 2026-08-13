--聖月の魔導士エンディミオン
-- 效果：
-- 包含魔法师族·4星怪兽的怪兽2只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡连接召唤的场合，以自己场上1只「大贤者」怪兽为对象才能发动。自己的墓地·除外状态的1只魔法师族怪兽当作装备魔法卡使用给作为对象的怪兽装备。
-- ②：自己·对方的主要阶段，以自己的魔法与陷阱区域1张当作装备魔法卡使用的魔法师族怪兽卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册连接素材条件（包含魔法师族·4星怪兽的怪兽2只）和召唤限制；注册①装备效果与②回手效果，并通过SetCountLimit(1,id)实现“这个卡名的①②的效果1回合只能有1次使用其中任意1个”的限制。
function s.initial_effect(c)
	-- 添加连接召唤手续：需要2只怪兽作为连接素材，且素材组必须满足s.lcheck，即其中至少包含1只魔法师族·4星怪兽（对应效果原文“包含魔法师族·4星怪兽的怪兽2只”）。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，以自己场上1只「大贤者」怪兽为对象才能发动。自己的墓地·除外状态的1只魔法师族怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以自己的魔法与陷阱区域1张当作装备魔法卡使用的魔法师族怪兽卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 连接素材的单个卡过滤条件：该怪兽必须是魔法师族且4星，用于保证素材组中包含魔法师族·4星怪兽。
function s.lfilter(c)
	return c:IsLinkRace(RACE_SPELLCASTER) and c:IsLevel(4)
end
-- 连接素材组检查：素材组g中是否存在至少1只满足s.lfilter的怪兽，即存在魔法师族·4星怪兽。
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- ①效果的发动条件：效果发动者为这张卡，且这张卡的召唤方式为连接召唤（即连接召唤成功时才能发动）。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果取对象的过滤条件：自己场上的表侧表示怪兽，且卡名属于「大贤者」系列（0x150）。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 装备卡检索过滤条件：该卡在墓地/除外区表侧表示、是魔法师族怪兽、装备到自己魔陷区时不会违反同名卡限制，且不是禁止装备的卡。
function s.eqfilter(c,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- ①效果的发动目标选择：选择自己场上1只表侧表示的「大贤者」怪兽为对象，同时需要自己魔陷区有空位、且墓地/除外区有可装备的魔法师族怪兽。若chkc指定对象则验证对象合法性。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 发动条件之一：自己魔陷区存在空闲区域，用于放置装备魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之一：自己场上存在至少1只表侧表示且属于「大贤者」的怪兽可以作为对象。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件之一：自己的墓地或除外区存在至少1张满足条件的魔法师族怪兽可以作为装备卡。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),tp) end
	-- 向操作玩家显示选择对象的提示信息“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「大贤者」怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：取得对象「大贤者」怪兽，若其仍与效果关联、表侧表示、是怪兽且自己魔陷区有空位，则从墓地/除外区选择1只魔法师族怪兽作为装备卡装备给对象，并给装备卡设置仅能装备给该对象的限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果的对象卡（「大贤者」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与效果关联、表侧表示、是怪兽卡，且自己魔陷区有空位，满足条件才继续装备处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己的墓地/除外区选择1张满足s.eqfilter且不受王家长眠之谷影响的魔法师族怪兽卡作为装备卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 尝试将选择的怪兽卡作为装备魔法卡装备给对象怪兽；若装备处理失败则结束效果处理。
			if not Duel.Equip(tp,ec,tc) then return end
			-- 为装备卡添加装备对象限制效果：该装备卡只能装备给对象怪兽（对应原文“当作装备魔法卡使用给作为对象的怪兽装备”）。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制判定函数：装备卡只能装备给之前记录的对象怪兽（LabelObject），用于保证装备卡只给选定的「大贤者」怪兽装备。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的发动条件：当前为双方主要阶段。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段，作为②效果的发动条件。
	return Duel.IsMainPhase()
end
-- ②效果对象的过滤条件：表侧表示、是装备卡、能够加入手卡，且其原本卡类为怪兽、原本种族为魔法师族（即魔陷区当作装备魔法卡使用的魔法师族怪兽卡）。
function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and c:GetOriginalRace()&RACE_SPELLCASTER==RACE_SPELLCASTER
end
-- ②效果的目标选择：选择自己魔法与陷阱区域1张符合条件的当作装备魔法卡使用的魔法师族怪兽卡为对象，并设定将该卡返回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.thfilter(chkc) end
	-- 发动条件检查：自己魔陷区是否存在至少1张符合条件的对象卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己魔陷区1张符合条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设定操作信息：本次效果处理要将1张卡返回持有者手牌，用于连锁检测与提示。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若其仍与效果关联，则将其返回持有者手卡（回手效果）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者手卡，原因为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
