--ライゼオル・ホールスラスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「雷火沸动」超量怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡破坏。那之后，可以从自己墓地把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。
-- ②：把墓地的这张卡除外才能发动。用包含「雷火沸动」怪兽的自己场上的怪兽为素材进行超量召唤。
local s,id,o=GetID()
-- 注册两个效果：①破坏效果和②超量召唤效果
function s.initial_effect(c)
	-- ①：以最多有自己场上的「雷火沸动」超量怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡破坏。那之后，可以从自己墓地把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。用包含「雷火沸动」怪兽的自己场上的怪兽为素材进行超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 效果cost：将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「雷火沸动」超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1be) and c:IsType(TYPE_XYZ)
end
-- 效果处理：判断是否满足发动条件，即自己场上存在「雷火沸动」超量怪兽且对方场上存在表侧表示的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 统计自己场上「雷火沸动」超量怪兽数量
	local gc=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return gc>0
		-- 判断对方场上是否存在表侧表示的卡
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示的卡，数量为「雷火沸动」超量怪兽数量
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,gc,nil)
	-- 设置效果操作信息：破坏选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 过滤条件：场上表侧表示的4阶超量怪兽且墓地存在可作为超量素材的「雷火沸动」卡
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4)
		-- 判断墓地是否存在可作为超量素材的「雷火沸动」卡
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,nil,e)
end
-- 过滤条件：「雷火沸动」卡且可叠放
function s.mtfilter(c,e)
	return c:IsSetCard(0x1be)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果处理：破坏目标卡，若满足条件则选择是否获取超量素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组并过滤出与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断是否成功破坏目标卡
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0
		-- 判断自己场上是否存在满足条件的4阶超量怪兽
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否选择获取超量素材
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否获取超量素材？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 选择满足条件的4阶超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local xc=g:GetFirst()
		-- 提示玩家选择作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择墓地中的「雷火沸动」卡作为超量素材
		local mg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
		if mg:GetCount()>0 then
			-- 将选中的卡叠放至目标怪兽上
			Duel.Overlay(xc,mg)
		end
	end
end
-- 过滤条件：场上可叠放的表侧表示怪兽
function s.filter(c)
	return c:IsCanOverlay() and c:IsFaceup()
end
-- 效果处理：判断是否满足发动条件，即自己场上存在可作为超量素材的怪兽且额外怪兽区存在满足条件的超量怪兽
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可作为超量素材的怪兽组
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 判断额外怪兽区是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,mg) end
	-- 设置效果操作信息：特殊召唤满足条件的超量怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：超量怪兽且其素材组满足条件
function s.xyzfilter2(c,mg)
	return c:IsType(TYPE_XYZ) and mg:CheckSubGroup(s.gselect,1,#mg,c)
end
-- 判断素材组是否包含「雷火沸动」卡且目标怪兽可进行XYZ召唤
function s.gselect(sg,c)
	return sg:IsExists(Card.IsSetCard,1,nil,0x1be) and c:IsXyzSummonable(sg,#sg,#sg)
end
-- 效果处理：从额外怪兽区特殊召唤超量怪兽并使用场上怪兽作为素材
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可作为超量素材的怪兽组
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外怪兽区满足条件的超量怪兽组
	local exg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if exg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=exg:Select(tp,1,1,nil)
		-- 提示玩家选择作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=mg:SelectSubGroup(tp,s.gselect,false,1,mg:GetCount(),tg:GetFirst())
		-- 进行XYZ召唤
		Duel.XyzSummon(tp,tg:GetFirst(),sg,#sg,#sg)
	end
end
