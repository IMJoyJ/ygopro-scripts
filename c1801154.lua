--遠心分離フィールド
-- 效果：
-- 融合怪兽因为卡的效果破坏送去墓地时，从自己墓地选择那只融合怪兽记述的1只融合素材，特殊召唤到自己场上。
function c1801154.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 融合怪兽因为卡的效果破坏送去墓地时，从自己墓地选择那只融合怪兽记述的1只融合素材，特殊召唤到自己场上。
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
		-- 融合怪兽因为卡的效果破坏送去墓地时，从自己墓地选择那只融合怪兽记述的1只融合素材，特殊召唤到自己场上。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c1801154.check)
		-- 将效果e2作为玩家0的效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有卡片因破坏效果被送入墓地时，检测该卡片是否为融合怪兽，若是则触发自定义事件EVENT_CUSTOM+1801154
function c1801154.check(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历因送入墓地而触发的卡片组eg中的每张卡片
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_FUSION) and tc:IsReason(REASON_DESTROY) and tc:IsReason(REASON_EFFECT) then
			-- 以卡片tc为触发对象，触发EVENT_CUSTOM+1801154事件
			Duel.RaiseEvent(tc,EVENT_CUSTOM+1801154,re,r,rp,tc:GetControler(),ev)
		end
	end
end
-- 判断卡片c是否为fc的融合素材，并且该卡片可以被特殊召唤
function c1801154.spfilter(c,e,tp,fc)
	-- 检测卡片c是否为fc的融合素材，并且该卡片可以被特殊召唤
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的条件判断，检查是否有满足条件的卡片可被选择
function c1801154.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local fc=eg:GetFirst()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1801154.spfilter(chkc,e,tp,fc) end
	-- 检查玩家tp的场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp的墓地中是否存在满足条件的卡片
		and Duel.IsExistingTarget(c1801154.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,fc) end
	-- 向玩家tp发送提示信息“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家tp的墓地中选择满足条件的1张卡片作为目标
	local g=Duel.SelectTarget(tp,c1801154.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fc)
	-- 设置当前连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标卡片特殊召唤到场上
function c1801154.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片tc以0方式特殊召唤到玩家tp的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
