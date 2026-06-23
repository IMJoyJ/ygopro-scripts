--サタンクロース
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上守备表示特殊召唤。
-- ②：这张卡用这张卡的①的方法特殊召唤的回合的结束阶段才能发动。自己抽1张。
function c46565218.initial_effect(c)
	-- 创建一个字段特殊召唤规则效果，允许从手卡守备表示特殊召唤
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
-- 过滤函数，检查对方场上是否存在可解放用于特殊召唤的怪兽且对方有可用怪兽区
function c46565218.spfilter(c,tp)
	-- 返回满足条件的怪兽数量大于0且对方有可用怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断特殊召唤条件是否满足，即对方场上有可解放的怪兽
function c46565218.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只可解放的怪兽
	return Duel.IsExistingMatchingCard(c46565218.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 选择要解放的怪兽并设置为效果对象
function c46565218.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有可解放的怪兽组
	local g=Duel.GetMatchingGroup(c46565218.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤后的处理，包括解放怪兽并设置抽卡效果
function c46565218.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤原因进行解放
	Duel.Release(g,REASON_SPSUMMON)
	-- 创建结束阶段触发的抽卡效果，仅在特殊召唤后使用一次
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
-- 设置抽卡效果的目标和参数
function c46565218.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作
function c46565218.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
