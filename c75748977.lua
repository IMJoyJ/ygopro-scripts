--XYZ－ハイパー・ドラゴン・キャノン
-- 效果：
-- 「X-交错加农」＋「Y-机敏龙头」＋「Z-无穷履带」
-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
-- ①：对方回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：把场上·墓地的这张卡除外，把额外卡组1只机械族·光属性·8星融合怪兽给对方观看才能发动。那只怪兽有卡名记述的自己的墓地·除外状态的最多3只融合素材怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合素材、接触融合特殊召唤手续、苏生限制、①对方回合丢手卡破坏卡片效果以及②除外自身特召展示怪兽记述素材效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册以「X-交错加农」＋「Y-机敏龙头」＋「Z-无穷履带」为融合素材
	aux.AddFusionProcCode3(c,70860415,6355563,33744268,true,true)
	-- 注册把场上·墓地上述素材除外进行特殊召唤的手续
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：对方回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：把场上·墓地的这张卡除外，把额外卡组1只机械族·光属性·8星融合怪兽给对方观看才能发动。那只怪兽有卡名记述的自己的墓地·除外状态的最多3只融合素材怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	-- 发动代价：把场上·墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤限制：不能从额外卡组以外特殊召唤（未正规召唤过时）
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- ①效果发动条件：当前为对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 发动代价：丢弃1张手卡
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否有可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果发动取对象及合法性检查
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏对象卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：破坏对象卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏对象卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤墓地或除外区记载于展示怪兽素材列表且可特殊召唤的怪兽
function s.spfilter(c,e,tp,fc)
	-- 检查怪兽是否表侧存在于除外区或墓地、是否为展示怪兽素材且可特殊召唤
	return c:IsFaceupEx() and aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查特召怪兽数量是否不超过空闲主要怪兽区数量
function s.fselect(tg,tp,ec)
	-- 检查空闲主要怪兽区数量是否足够
	return Duel.GetMZoneCount(tp,ec,tp)>=#tg
end
-- 过滤额外卡组机械族·光属性·8星且有可用素材在墓地或除外区的融合怪兽
function s.ffilter(c,e,tp,ec)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(8)) then return false end
	-- 获取墓地和除外区所有可特殊召唤的素材怪兽
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,c)
	return tg:CheckSubGroup(s.fselect,1,3,tp,ec)
end
-- ②效果发动目标检查及展示额外融合怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组是否存在符合条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 提示选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择额外卡组1只机械族·光属性·8星融合怪兽
	local fc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	-- 向对方展示该融合怪兽
	Duel.ConfirmCards(1-tp,fc)
	e:SetLabelObject(fc)
	-- 设置操作信息：从墓地·除外状态特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：特殊召唤展示怪兽卡名记述的墓地·除外状态最多3只融合素材怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区域的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fc=e:GetLabelObject()
	-- 获取墓地和除外区不受王家长眠之谷影响的素材怪兽
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,fc)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的素材怪兽中选择最多3只
	local g=mg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
	-- 将选中的素材怪兽表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
