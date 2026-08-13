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
-- ①效果的触发条件过滤器：确认被召唤/特殊召唤成功的怪兽是表侧表示、属于「超级运动员」字段，且召唤玩家为自己。
function c47021196.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and c:IsSummonPlayer(tp)
end
-- ①效果的触发条件：本次召唤/特殊召唤成功的事件中存在至少1只满足cfilter条件的「超级运动员」怪兽。
function c47021196.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47021196.cfilter,1,nil,tp)
end
-- ①效果的发动处理：在检查发动合法性时，确认自己主要怪兽区有空位且手卡的这张卡能够被特殊召唤；合法后设置特殊召唤的操作信息。
function c47021196.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动合法性检查：自己主要怪兽区存在可用空格，且这张卡满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- ①效果的操作信息：将该效果登记为特殊召唤1只怪兽（即手卡中的这张卡）的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若自己主要怪兽区仍有空位且这张卡仍与此效果关联，则将其表侧攻击表示特殊召唤。
function c47021196.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ①效果处理前确认：如果自己主要怪兽区没有可用空格，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- ①效果处理：将这张卡从手卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果中“效果无效”选项的怪物过滤器：选择可被无效且未被无效的表侧效果怪兽，并且该怪兽不是「超级运动员」字段怪兽。
function c47021196.negfilter(c)
	-- ②效果无效选项的筛选条件：怪兽必须是表侧表示的效果怪兽（可被无效），且不属于「超级运动员」字段。
	return aux.NegateMonsterFilter(c) and not c:IsSetCard(0xb2)
end
-- ②效果的目标/选择处理：根据场上是否有可破坏的卡或可无效的怪兽来决定显示哪些选项，让玩家选择“破坏”或“无效”；选择破坏时指定取对象破坏，选择无效时设置无效分类。
function c47021196.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- ②效果中“破坏”选项的可用性判断：获取场上所有卡的集合，用于确认是否存在可以选择的破坏对象。
	local b1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- ②效果中“无效”选项的可用性判断：获取双方怪兽区中满足negfilter的怪兽，用于确认是否存在可以无效的怪兽。
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
	-- ②效果发动时让玩家选择要适用的效果分支（0或1），加1转为Lua数组下标，得到实际选择值。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		-- ②效果选择破坏分支时，向玩家显示“请选择要破坏的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- ②效果破坏分支：选择场上1张卡作为效果对象。
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- ②效果破坏分支的操作信息：登记将破坏选中的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_DELAY)
	end
end
-- ②效果处理：根据发动时选择的分支执行。若选择破坏，则破坏所选对象；若选择无效，则对场上所有非「超级运动员」表侧效果怪兽无效化其效果直到回合结束。
function c47021196.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- ②效果破坏分支：取得发动时选择的对象卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- ②效果破坏分支：因效果破坏该对象卡。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		-- ②效果无效分支：重新获取当前场上非「超级运动员」且可被无效的表侧效果怪兽，用于逐个无效化。
		local b2=Duel.GetMatchingGroup(c47021196.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local nc=b2:GetFirst()
		while nc do
			-- 「超级运动员」怪兽以外的场上的全部表侧表示怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e1)
			-- 「超级运动员」怪兽以外的场上的全部表侧表示怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e2)
			nc=b2:GetNext()
		end
	end
end
