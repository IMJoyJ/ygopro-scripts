--インフェルニティ・フォース
-- 效果：
-- 自己手卡是0张的场合，名字带有「永火」的怪兽被选择作为攻击对象时才能发动。把1只攻击怪兽破坏，选择自己墓地存在的1只名字带有「永火」的怪兽特殊召唤。
function c18712704.initial_effect(c)
	-- 自己手卡是0张的场合，名字带有「永火」的怪兽被选择作为攻击对象时才能发动。把1只攻击怪兽破坏，选择自己墓地存在的1只名字带有「永火」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c18712704.condition)
	e1:SetTarget(c18712704.target)
	e1:SetOperation(c18712704.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：自己手卡为0张，且被选择为攻击对象的「永火」怪兽为表侧表示。
function c18712704.condition(e,tp,eg,ep,ev,re,r,rp)
	local att=eg:GetFirst()
	-- 判断自己手卡数量是否为0、攻击对象是否表侧表示、攻击对象是否属于「永火」。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and att:IsFaceup() and att:IsSetCard(0xb)
end
-- 定义墓地「永火」怪兽的特殊召唤筛选条件：卡名含有「永火」且满足特殊召唤条件。
function c18712704.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理：确定攻击怪兽为破坏对象，并选择墓地1只「永火」怪兽作为特殊召唤对象，同时检查发动条件是否满足。
function c18712704.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽，作为将被破坏的对象。
	local tg=Duel.GetAttacker()
	if chkc then return false end
	-- 在效果发动时检查攻击怪兽是否在场上、能否被效果破坏、能否成为效果对象，以及自己场上是否有可用的怪兽区域。
	if chk==0 then return tg:IsOnField() and tg:IsDestructable() and tg:IsCanBeEffectTarget(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只符合条件的「永火」怪兽可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c18712704.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将攻击怪兽设置为效果关联的对象。
	Duel.SetTargetCard(tg)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「永火」怪兽作为特殊召唤对象，并设置为效果对象。
	local g=Duel.SelectTarget(tp,c18712704.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理中要进行的破坏操作信息：破坏攻击怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 设置效果处理中要进行的特殊召唤操作信息：特殊召唤选择的墓地「永火」怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的实际操作：若攻击怪兽仍与效果关联且为攻击表示，将其破坏；若选择的墓地怪兽仍与效果关联、自己场上有空位且满足特殊召唤条件，则将其表侧表示特殊召唤。
function c18712704.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前记录的特殊召唤操作信息中的对象组（要特殊召唤的卡）。
	local ex,sg=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	-- 获取之前记录的破坏操作信息中的对象组（要破坏的卡）。
	local ex,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local sc=sg:GetFirst()
	local dc=dg:GetFirst()
	if dc:IsRelateToEffect(e) and dc:IsAttackPos() then
		-- 以效果原因将攻击怪兽破坏。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 检查要特殊召唤的卡是否仍与效果关联，以及自己场上是否有可用怪兽区域。
		if sc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选择的墓地「永火」怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
