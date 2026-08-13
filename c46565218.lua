--サタンクロース
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上守备表示特殊召唤。
-- ②：这张卡用这张卡的①的方法特殊召唤的回合的结束阶段才能发动。自己抽1张。
function c46565218.initial_effect(c)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,1)
	e1:SetCondition(c46565218.spcon)
	e1:SetTarget(c46565218.sptg)
	e1:SetOperation(c46565218.spop)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤解放对象的筛选函数：对象必须能被解放（用于特殊召唤），并且解放后对方场上仍有可用的主要怪兽区。
function c46565218.spfilter(c,tp)
	-- 判定该卡可作为特殊召唤的解放对象，且解放后对方场上仍有可用的主要怪兽区空位。
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 定义①效果的特殊召唤条件：若c为nil（规则询问）直接通过；否则需对方场上有满足spfilter的可解放怪兽且解放后有空位。
function c46565218.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只满足spfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(c46565218.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 定义①效果的解放对象选择处理：从对方场上的符合条件的怪兽中选择1只作为解放对象，并存入效果标签；若未选择则特殊召唤不进行。
function c46565218.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足spfilter条件的怪兽组成候选组。
	local g=Duel.GetMatchingGroup(c46565218.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示，用于选择解放对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义①效果处理时的操作：解放已选择的对方怪兽，将这张卡特殊召唤到对方场上（表侧守备表示），并给这张卡注册结束阶段抽卡的②效果。
function c46565218.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为理由解放选定的对方怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	-- ②：这张卡用这张卡的①的方法特殊召唤的回合的结束阶段才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46565218,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetTarget(c46565218.drtg)
	e1:SetOperation(c46565218.drop)
	e1:SetReset(RESET_EVENT+0xec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 定义②效果的发动条件与效果信息：确认玩家可以抽卡，并设定抽卡对象为这张卡的控制者、抽卡数为1。
function c46565218.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时，若玩家不能抽1张卡则不能发动，否则允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设为这张卡的控制者。
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：该效果属于抽卡效果，预计抽卡玩家为tp，抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果处理时的操作：根据之前设定的对象玩家和抽卡数量执行抽卡。
function c46565218.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果设定的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果理由让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
