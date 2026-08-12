--U.A.プレイングマネージャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对「超级运动员」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合，可以从以下效果选择1个发动。
-- ●以场上1张卡为对象才能发动。那张卡破坏。
-- ●「超级运动员」怪兽以外的场上的全部表侧表示怪兽的效果直到回合结束时无效。
function c47021196.initial_effect(c)
	-- ①：自己对「超级运动员」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47021196,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,47021196)
	e1:SetCondition(c47021196.spcon)
	e1:SetTarget(c47021196.sptg)
	e1:SetOperation(c47021196.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，可以从以下效果选择1个发动。●以场上1张卡为对象才能发动。那张卡破坏。●「超级运动员」怪兽以外的场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,47021197)
	e3:SetTarget(c47021196.target)
	e3:SetOperation(c47021196.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「超级运动员」怪兽（表侧表示、自己召唤的）
function c47021196.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and c:IsSummonPlayer(tp)
end
-- 判断是否有满足条件的「超级运动员」怪兽被召唤或特殊召唤成功
function c47021196.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47021196.cfilter,1,nil,tp)
end
-- 设置特殊召唤的处理信息，准备将此卡特殊召唤到场上
function c47021196.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件：场上存在空位且此卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示此效果会将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作函数
function c47021196.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选满足条件的非「超级运动员」怪兽（表侧表示、未被无效化）
function c47021196.negfilter(c)
	-- 判断一个怪兽是否为表侧表示、未被无效化且不是「超级运动员」怪兽
	return aux.NegateMonsterFilter(c) and not c:IsSetCard(0xb2)
end
-- 设置选择效果的处理信息，准备让玩家选择破坏或无效的效果
function c47021196.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 获取场上所有表侧表示的卡（用于破坏效果）
	local b1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 获取场上所有满足条件的非「超级运动员」怪兽（用于无效效果）
	local b2=Duel.GetMatchingGroup(c47021196.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #b1>0 or #b2>0 end
	local off=1
	local ops={}
	local opval={}
	if #b1>0 then
		ops[off]=aux.Stringid(47021196,1)  --"卡片破坏"
		opval[off]=0
		off=off+1
	end
	if #b2>0 then
		ops[off]=aux.Stringid(47021196,2)  --"效果无效"
		opval[off]=1
		off=off+1
	end
	-- 让玩家从可选效果中选择一个
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择一张场上卡作为破坏目标
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置操作信息，表示此效果会破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_DELAY)
	end
end
-- 执行选择的效果操作函数
function c47021196.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 以效果原因破坏目标卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		-- 获取场上所有满足条件的非「超级运动员」怪兽（用于无效效果）
		local b2=Duel.GetMatchingGroup(c47021196.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local nc=b2:GetFirst()
		while nc do
			-- 创建一个使目标怪兽效果无效的EFFECT_DISABLE效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e1)
			-- 创建一个使目标怪兽效果无效化的EFFECT_DISABLE_EFFECT效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e2)
			nc=b2:GetNext()
		end
	end
end
