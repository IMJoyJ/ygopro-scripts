--遠心分離フィールド
-- 效果：
-- 融合怪兽因为卡的效果破坏送去墓地时，从自己墓地选择那只融合怪兽记述的1只融合素材，特殊召唤到自己场上。
function c1801154.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 从自己墓地选择那只融合怪兽记述的1只融合素材，特殊召唤到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1801154,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CUSTOM+1801154)
	e2:SetTarget(c1801154.sptg)
	e2:SetOperation(c1801154.spop)
	c:RegisterEffect(e2)
	if not c1801154.global_check then
		c1801154.global_check=true
		-- 融合怪兽因为卡的效果破坏送去墓地时
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c1801154.check)
		-- 将全局监测效果ge1注册到游戏中，使双方场上每次有卡送去墓地时都会触发check操作。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义check函数：遍历本次送去墓地的全部卡，找出因卡的效果被破坏的融合怪兽，并为其触发自定义事件，作为本卡的诱发效果发动契机。
function c1801154.check(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历本次送去墓地的卡组eg，逐张检查是否符合条件。
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_FUSION) and tc:IsReason(REASON_DESTROY) and tc:IsReason(REASON_EFFECT) then
			-- 对符合条件的融合怪兽触发自定义事件EVENT_CUSTOM+1801154，从而让处于场地区的本卡效果得以发动，并传递原破坏效果的信息。
			Duel.RaiseEvent(tc,EVENT_CUSTOM+1801154,re,r,rp,tc:GetControler(),ev)
		end
	end
end
-- 定义spfilter筛选函数：判断墓地中的候选卡是否为那只融合怪兽记述的融合素材，且能否被特殊召唤。
function c1801154.spfilter(c,e,tp,fc)
	-- 判定候选卡c的卡名记录在融合怪兽fc的融合素材列表中，且c能被tp以效果e特殊召唤（不检查召唤条件与苏生限制）。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义sptg目标选择函数：以触发事件的融合怪兽为素材基准，检查我方怪兽区是否有空位、墓地是否存在可选素材，若有则让玩家选择1张。
function c1801154.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local fc=eg:GetFirst()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1801154.spfilter(chkc,e,tp,fc) end
	-- 效果发动时检查我方主要怪兽区是否存在可用空格，无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在满足spfilter的融合素材卡（可作为效果对象），确保发动时一定能选到素材。
		and Duel.IsExistingTarget(c1801154.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,fc) end
	-- 向玩家tp显示“请选择要特殊召唤的卡”的提示消息，用于后续选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp从自己墓地选择1张满足条件的融合素材，并将其设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c1801154.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fc)
	-- 将效果处理信息登记为特殊召唤1张卡，对象为g，供其他卡/效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义spop效果处理函数：处理时将之前选择的对象卡特殊召唤到自己场上。
function c1801154.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时仍然与效果关联的对象卡（即玩家选择的融合素材）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将素材卡以表侧表示特殊召唤到tp场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
