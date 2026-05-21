--影霊翼騎 ウェンディクルフ
-- 效果：
-- 「影依」怪兽＋风属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤限制、①效果（自由时点改变表示形式）和②效果（送墓回收墓地「影依」卡）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「影依」怪兽＋风属性怪兽。
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WIND)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"变成表侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 限制该卡只能通过融合召唤从额外卡组特殊召唤。
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ①效果的发动准备，确认场上是否存在里侧表示怪兽，并设置改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只里侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置改变表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,PLAYER_ALL,0)
end
-- ①效果的处理：让玩家选择场上任意数量的里侧怪兽变成表侧守备表示，统计其中的反转怪兽数量，再选择最多该数量的、除刚翻开的怪兽以外的表侧怪兽变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的里侧表示怪兽。
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #dg==0 then return end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择任意数量（1张以上）的里侧表示怪兽。
	local fg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,#dg,nil)
	if #fg>0 then
		-- 选中所选的怪兽并闪烁显示。
		Duel.HintSelection(fg)
		-- 将选中的怪兽变成表侧守备表示。
		Duel.ChangePosition(fg,POS_FACEUP_DEFENSE)
	end
	local fct=fg:FilterCount(Card.IsType,nil,TYPE_FLIP)
	if fct>0 then
		-- 获取场上除刚刚变成表侧守备表示的怪兽以外的所有可以变成里侧守备表示的表侧表示怪兽。
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,fg)
		-- 如果存在可选的表侧表示怪兽，询问玩家是否要将怪兽变成里侧守备表示。
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽变成里侧守备表示？"
			-- 提示玩家选择要变成里侧守备表示的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=tg:Select(tp,1,math.min(fct,#tg),nil)
			if #sg>0 then
				-- 插入效果处理间隔，使前后的表示形式改变不视为同时处理。
				Duel.BreakEffect()
				-- 选中要变成里侧守备表示的怪兽并闪烁显示。
				Duel.HintSelection(sg)
				-- 将选中的怪兽变成里侧守备表示。
				Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
-- 过滤条件：自己墓地的「影依」卡且能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- ②效果的发动准备：以自己墓地1张「影依」卡为对象发动，设置回收卡片的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的「影依」卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「影依」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将选中的卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将作为对象的墓地「影依」卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与连锁相关，并应用「王家之谷」的无效化过滤。
	if tc:IsRelateToChain() and aux.NecroValleyFilter(tc) then
		-- 将对象卡加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
