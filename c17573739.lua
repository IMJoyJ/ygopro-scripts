--神禽王アレクトール
-- 效果：
-- 对方场上相同属性的怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。1回合1次选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。「神禽王 亚力克特」在场上只能有1张表侧表示存在。
function c17573739.initial_effect(c)
	c:SetUniqueOnField(1,1,17573739)
	-- 对方场上相同属性的怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17573739.spcon)
	c:RegisterEffect(e1)
	-- 1回合1次选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17573739,0))  --"效果无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c17573739.distg)
	e2:SetOperation(c17573739.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查对方场上的怪兽c是否表侧表示，且对方场上还存在另一只与c属性相同的表侧表示怪兽。
function c17573739.spfilter1(c,tp)
	-- 以c为基准，判断对方场上是否存在另一只与该怪兽属性相同的表侧表示怪兽，用于满足“相同属性2只以上”的条件。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c17573739.spfilter2,tp,0,LOCATION_MZONE,1,c,c:GetAttribute())
end
-- 过滤函数：判断怪兽c是否表侧表示且属性等于att，用于匹配与基准怪兽相同属性的其他怪兽。
function c17573739.spfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 特殊召唤规则条件：c==nil时用于询问是否允许规则特殊召唤，返回true；否则判定我方主要怪兽区有空位且对方场上有2只以上相同属性的表侧表示怪兽。
function c17573739.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否有可用空格，确保手牌的这张卡能够特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方主要怪兽区是否存在满足spfilter1条件的怪兽，即存在一只表侧表示怪兽且场上另有与其相同属性的表侧表示怪兽，从而满足特殊召唤条件。
		and	Duel.IsExistingMatchingCard(c17573739.spfilter1,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 起动效果的发动条件与目标选择：指定对象时必须是场上表侧表示的卡；发动时确认场上有可选的表侧表示卡；随后提示玩家选择1张场上表侧表示的卡作为对象。
function c17573739.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 效果发动时检查：若场上不存在任何表侧表示卡可供选择，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示选择提示信息，提示内容为“请选择表侧表示的卡”（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方场上选择1张表侧表示的卡，将其登记为这张效果的对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：取得效果来源与对象卡；若对象仍表侧表示、与效果仍有关联且其效果可被无效，则对对象附加效果无效化处理：无效其怪兽效果、无效其效果，并若为陷阱怪兽则追加无效陷阱怪兽状态，这些无效效果持续到结束阶段。
function c17573739.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁中这张效果选定的对象卡（本效果只选1张，因此用GetFirstTarget取得）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 选择的卡的效果在那个回合中无效（通过EFFECT_DISABLE无效对象怪兽的怪兽效果）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 选择的卡的效果在那个回合中无效（通过EFFECT_DISABLE_EFFECT无效对象卡的效果）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 选择的卡的效果在那个回合中无效（对陷阱怪兽追加无效陷阱怪兽状态）。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
