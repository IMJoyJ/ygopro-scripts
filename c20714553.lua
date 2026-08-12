--聖月の魔導士エンディミオン
-- 效果：
-- 包含魔法师族·4星怪兽的怪兽2只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡连接召唤的场合，以自己场上1只「大贤者」怪兽为对象才能发动。自己的墓地·除外状态的1只魔法师族怪兽当作装备魔法卡使用给作为对象的怪兽装备。
-- ②：自己·对方的主要阶段，以自己的魔法与陷阱区域1张当作装备魔法卡使用的魔法师族怪兽卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求使用2~2个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，以自己场上1只「大贤者」怪兽为对象才能发动。
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
	-- ②：自己·对方的主要阶段，以自己的魔法与陷阱区域1张当作装备魔法卡使用的魔法师族怪兽卡为对象才能发动。
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
-- 连接素材过滤函数，判断是否为魔法师族4星怪兽
function s.lfilter(c)
	return c:IsLinkRace(RACE_SPELLCASTER) and c:IsLevel(4)
end
-- 连接召唤条件检查函数，判断连接素材中是否存在魔法师族4星怪兽
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- 效果①的发动条件，判断此卡是否为连接召唤
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的目标过滤函数，判断是否为「大贤者」怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 效果①的装备卡过滤函数，判断是否为魔法师族怪兽且未被禁止
function s.eqfilter(c,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 效果①的发动时选择目标函数，判断是否满足选择目标和装备卡的条件
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 判断场上是否有足够的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在「大贤者」怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断墓地或除外区是否存在魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择「大贤者」怪兽作为效果对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理函数，执行装备操作
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且满足装备条件
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择满足条件的魔法师族怪兽作为装备卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 执行装备操作，若失败则返回
			if not Duel.Equip(tp,ec,tc) then return end
			-- 设置装备限制效果，确保装备卡只能装备给指定怪兽
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
-- 装备限制效果的判断函数，判断是否为指定对象
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件，判断是否为主阶段
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为主阶段
	return Duel.IsMainPhase()
end
-- 效果②的目标过滤函数，判断是否为魔法师族装备卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and c:GetOriginalRace()&RACE_SPELLCASTER==RACE_SPELLCASTER
end
-- 效果②的发动时选择目标函数，判断是否满足选择目标的条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.thfilter(chkc) end
	-- 判断场上是否存在满足条件的装备卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的装备卡作为目标
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设置操作信息，指定将装备卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理函数，执行将装备卡送回手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
