--XYZ－ハイパー・ドラゴン・キャノン
-- 效果：
-- 「X-交错加农」＋「Y-机敏龙头」＋「Z-无穷履带」
-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
-- ①：对方回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：把场上·墓地的这张卡除外，把额外卡组1只机械族·光属性·8星融合怪兽给对方观看才能发动。那只怪兽有卡名记述的自己的墓地·除外状态的最多3只融合素材怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，设置召唤限制、融合素材、接触融合手续、特殊召唤限制及两个发动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「X-交错加农」、「Y-机敏龙头」和「Z-无穷履带」。
	aux.AddFusionProcCode3(c,70860415,6355563,33744268,true,true)
	-- 添加接触融合召唤手续，将自己场上·墓地的素材除外。
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
	-- 设置效果发动代价为将场上·墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 限制该卡从额外卡组特殊召唤时必须满足上述特殊召唤条件。
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：只能在对方回合发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①的发动代价：丢弃1张手卡。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的靶向与准备：选择对方场上1张卡作为对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：破坏作为对象的卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的发动对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：筛选是指定融合怪兽的素材且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp,fc)
	-- 判定卡片是否在融合怪兽的素材列表中，且当前可以被特殊召唤。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域是否有足够的空位来特殊召唤选定的素材怪兽。
function s.fselect(tg,tp,ec)
	-- 判定在当前卡片离开场后，怪兽区域的空位数是否大于或等于要特殊召唤的怪兽数量。
	return Duel.GetMZoneCount(tp,ec,tp)>=#tg
end
-- 过滤函数：筛选额外卡组中符合条件的机械族·光属性·8星融合怪兽，且其记述的素材在墓地或除外状态中存在可特召的组合。
function s.ffilter(c,e,tp,ec)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(8)) then return false end
	-- 获取自己墓地及除外状态中，属于该融合怪兽素材且可特召的怪兽集合。
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,c)
	return tg:CheckSubGroup(s.fselect,1,3,tp,ec)
end
-- 效果②的发动准备：确认额外卡组中符合条件的融合怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组是否存在符合条件的融合怪兽，且其素材满足特召条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组选择1只符合条件的融合怪兽。
	local fc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	-- 将选中的融合怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,fc)
	e:SetLabelObject(fc)
	-- 设置效果处理信息为从墓地或除外状态特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的效果处理：选择被确认怪兽所记述的、位于自己墓地或除外状态的最多3只素材怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fc=e:GetLabelObject()
	-- 获取自己墓地及除外状态中，不受「王家之谷」影响且属于该融合怪兽素材的可特召怪兽集合。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,fc)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在可特召数量限制内，选择最多3只符合条件的素材怪兽。
	local g=mg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
