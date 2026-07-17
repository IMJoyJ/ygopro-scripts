--影霊翼騎 ウェンディクルフ
-- 效果：
-- 「影依」怪兽＋风属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化这张卡的各个效果：设置苏生限制与影依融合素材条件，注册融合召唤限制的效果外文本、①的改变表示形式的诱发即时效果（1回合1次）以及②的送墓回收墓地的触发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定这张卡的融合素材为「影依」怪兽＋风属性怪兽
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WIND)
	-- 「影依」怪兽＋风属性怪兽。这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方回合可以发动。场上的里侧表示怪兽任意数量变成表侧守备表示。那之后，可以把最多有那之内的反转怪兽数量的除变成表侧守备表示的怪兽以外的表侧表示怪兽变成里侧守备表示。
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
-- 特殊召唤条件：只有用融合召唤进行的特殊召唤才被允许
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ①效果的目标函数：发动条件检查时要求双方场上存在至少1只里侧表示怪兽，并登记改变表示形式的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方的主要怪兽区及额外怪兽区必须存在至少1只里侧表示怪兽才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 登记本连锁将处理改变表示形式分类的操作信息（数量处理时才能确定，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,PLAYER_ALL,0)
end
-- ①效果的处理：让发动玩家选择双方场上任意数量的里侧表示怪兽变成表侧守备表示，再统计其中反转怪兽的数量，若大于0则可以再把最多那个数量的其他表侧表示怪兽变成里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上所有里侧表示的怪兽
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #dg==0 then return end
	-- 向玩家提示「请选择要改变表示形式的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方场上的里侧表示怪兽中选择1只到全部数量的怪兽，准备变成表侧守备表示
	local fg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,#dg,nil)
	if #fg>0 then
		-- 为选中的里侧表示怪兽显示被选中的动画效果
		Duel.HintSelection(fg)
		-- 把选中的里侧表示怪兽变成表侧守备表示（会触发反转及反转效果）
		Duel.ChangePosition(fg,POS_FACEUP_DEFENSE)
	end
	local fct=fg:FilterCount(Card.IsType,nil,TYPE_FLIP)
	if fct>0 then
		-- 取得除刚才变成表侧守备表示的怪兽以外、双方场上表侧表示且可以变成里侧守备表示的怪兽
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,fg)
		-- 若存在可盖放的怪兽，询问玩家是否把怪兽变成里侧守备表示
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽变成里侧守备表示？"
			-- 向玩家提示「请选择要改变表示形式的怪兽」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=tg:Select(tp,1,math.min(fct,#tg),nil)
			if #sg>0 then
				-- 中断当前效果处理，使之后的盖放处理与前面的翻转处理视为不同时进行
				Duel.BreakEffect()
				-- 为选中的要盖放的怪兽显示被选中的动画效果
				Duel.HintSelection(sg)
				-- 把选中的表侧表示怪兽变成里侧守备表示
				Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
-- 回收过滤条件：是「影依」卡（系列0x9d）且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- ②效果的目标函数：检查自己墓地是否存在可作为对象的「影依」卡，让玩家选择1张作为对象，并登记加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检查：自己墓地必须存在至少1张可以成为效果对象且可加入手卡的「影依」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张「影依」卡作为这个效果的对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本连锁将把作为对象的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：取得作为对象的卡，若其仍与本连锁关联且不受王家长眠之谷影响，则将其加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与本连锁关联，且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 以效果原因把对象卡加入其持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
