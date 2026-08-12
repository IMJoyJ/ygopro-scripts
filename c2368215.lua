--魔界劇団－ハイパー・ディレクター
-- 效果：
-- 「魔界剧团」灵摆怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。那之后，从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选和特殊召唤的怪兽卡名不同的1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能召唤·特殊召唤。
function c2368215.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1张以上1张以下的「魔界剧团」灵摆怪兽作为连接素材
	aux.AddLinkProcedure(c,c2368215.mfilter,1,1)
	-- ①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。那之后，从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选和特殊召唤的怪兽卡名不同的1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2368215,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,2368215)
	e1:SetTarget(c2368215.sptg)
	e1:SetOperation(c2368215.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断卡片是否为「魔界剧团」灵摆怪兽
function c2368215.mfilter(c)
	return c:IsLinkSetCard(0x10ec) and c:IsLinkType(TYPE_PENDULUM)
end
-- 过滤函数，判断卡片是否可以被特殊召唤且满足后续条件
function c2368215.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的额外卡组或卡组中的灵摆怪兽
		and Duel.IsExistingMatchingCard(c2368215.stfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数，判断卡片是否为「魔界剧团」灵摆怪兽且不与指定卡名相同
function c2368215.stfilter(c,code)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and not c:IsCode(code) and not c:IsForbidden()
end
-- 设置效果的发动条件，检查是否有满足条件的灵摆区域卡片可作为对象
function c2368215.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c2368215.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家灵摆区域是否存在满足条件的卡片
		and Duel.IsExistingTarget(c2368215.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的灵摆区域卡片作为效果对象
	local g=Duel.SelectTarget(tp,c2368215.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤和后续放置灵摆怪兽的操作
function c2368215.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否仍然存在于场上并成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查玩家灵摆区域是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		local code=tc:GetCode()
		-- 从卡组或额外卡组选择满足条件的灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c2368215.stfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,code)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的灵摆怪兽放置到玩家的灵摆区域
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
	-- 创建并注册不能召唤「魔界剧团」怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2368215.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将效果e2注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制效果，禁止召唤非「魔界剧团」怪兽
function c2368215.splimit(e,c)
	return not c:IsSetCard(0x10ec)
end
