--影霊翼騎 ウェンディクルフ
-- 效果：
-- 「影依」怪兽＋风属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册苏生限制与融合素材条件、特殊召唤条件（效果外文本）、①的诱发即时效果、②的送墓诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册影依融合怪兽专用的融合素材条件：「影依」怪兽＋风属性怪兽
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WIND)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。（这个卡名的①的效果1回合只能使用1次）
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
-- 特殊召唤条件的判定：只有用融合召唤才能从额外卡组特殊召唤这张卡
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ①效果的对象选择阶段：检查场上是否存在里侧表示怪兽，并登记改变表示形式的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方的主要怪兽区合计至少存在1张里侧表示怪兽才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 登记本连锁的操作信息：分类为改变表示形式效果，处理对象在处理时才确定
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,PLAYER_ALL,0)
end
-- ①效果的处理：把任意数量的里侧表示怪兽变成表侧守备表示，再按其中反转怪兽的数量把其他表侧表示怪兽变成里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方主要怪兽区所有里侧表示怪兽的卡片组
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #dg==0 then return end
	-- 提示发动的玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从里侧表示怪兽中选择任意数量（1张至全部）要变成表侧守备表示的怪兽
	local fg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,#dg,nil)
	if #fg>0 then
		-- 为选择的怪兽显示被选中的动画
		Duel.HintSelection(fg)
		-- 把选择的里侧表示怪兽变成表侧守备表示
		Duel.ChangePosition(fg,POS_FACEUP_DEFENSE)
	end
	local fct=fg:FilterCount(Card.IsType,nil,TYPE_FLIP)
	if fct>0 then
		-- 取得除刚变成表侧守备表示的怪兽以外、可以变成里侧守备表示的表侧表示怪兽的卡片组
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,fg)
		-- 若有可选的怪兽，询问玩家是否把怪兽变成里侧守备表示
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽变成里侧守备表示？"
			-- 提示玩家选择要变成里侧守备表示的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=tg:Select(tp,1,math.min(fct,#tg),nil)
			if #sg>0 then
				-- 中断效果处理，使「那之后」的处理不与前面的处理视为同时处理
				Duel.BreakEffect()
				-- 为选择的怪兽显示被选中的动画
				Duel.HintSelection(sg)
				-- 把选择的表侧表示怪兽变成里侧守备表示
				Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
-- ②效果的过滤条件：自己墓地的「影依」卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- ②效果的对象选择阶段：以自己墓地1张「影依」卡为对象并登记加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检查：自己墓地存在可以成为对象的「影依」卡才能发动
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 以自己墓地1张「影依」卡为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本连锁的操作信息：把作为对象的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：确认对象仍与连锁相关且不受王家长眠之谷影响后，把那张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与连锁相关且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 以效果处理为原因把作为对象的卡加入持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
