--虚蝕異解△ジャハンナム
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①及各除外卡数量效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。从自己卡组上面把8张卡里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ●10张以上：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.recon(10))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ●20张以上：1回合1次，以场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.recon(20))
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ●30张以上：对方结束阶段才能发动。从自己除外状态的里侧表示卡中选1张加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- ●40张以上：双方跳过抽卡阶段。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetCode(EFFECT_SKIP_DP)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.recon(40))
	c:RegisterEffect(e6)
end
-- 除外效果发动准备与操作信息设置
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的8张卡
	local dg=Duel.GetDecktopGroup(tp,8)
	if chk==0 then return true end
	-- 设置操作信息：将卡组顶端的8张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：将自己卡组顶端8张卡里侧表示除外并注册标记
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的8张卡
	local dg=Duel.GetDecktopGroup(tp,8)
	if dg and dg:GetCount()>0 then
		-- 关闭洗牌检查
		Duel.DisableShuffleCheck()
		-- 将卡组顶端的卡里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被除外的卡片组
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
				end
			end
		end
	end
end
-- 生成检查场上双方除外状态的里侧表示卡数量是否达到设定值的条件函数
function s.recon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
			-- 检查双方除外状态的里侧表示卡总数是否达到指定数量
			return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)>=ct
		end
end
-- 选择场上1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏目标卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 回收效果的发动条件：对方回合结束阶段且里侧除外卡达到30张以上
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合且里侧除外卡达到30张以上
	return Duel.GetTurnPlayer()~=tp and s.recon(30)(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤除外状态的可以加入手牌的里侧表示卡
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 回收效果发动准备与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己除外状态是否存在可以加入手牌的里侧表示卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从除外区将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：从自己除外的里侧表示卡中选1张加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己除外状态的里侧表示卡中选择1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的卡片被选为对象
		Duel.HintSelection(g)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
