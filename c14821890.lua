--相剣暗転
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只幻龙族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
function c14821890.initial_effect(c)
	-- ①：以自己场上1只幻龙族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,14821890)
	e1:SetTarget(c14821890.target)
	e1:SetOperation(c14821890.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14821890,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,14821891)
	e2:SetTarget(c14821890.sptg)
	e2:SetOperation(c14821890.spop)
	c:RegisterEffect(e2)
end
-- 过滤场上正面表示的幻龙族怪兽
function c14821890.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM)
end
-- 效果①的发动时点处理函数
function c14821890.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只正面表示的幻龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c14821890.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在2张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择自己场上1只正面表示的幻龙族怪兽作为对象
	local g1=Duel.SelectTarget(tp,c14821890.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上2张卡作为对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果①的发动处理函数
function c14821890.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡组中与效果相关的卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 效果②的发动时点处理函数
function c14821890.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置效果处理时要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理时要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的发动处理函数
function c14821890.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 创建1只相剑衍生物
		local token=Duel.CreateToken(tp,14821891)
		-- 将相剑衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 创建一个限制非同调怪兽从额外卡组特殊召唤的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c14821890.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 限制非同调怪兽从额外卡组特殊召唤的效果处理函数
function c14821890.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
