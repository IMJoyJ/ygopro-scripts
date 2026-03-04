--ガーディアン・キマイラ
-- 效果：
-- 卡名不同的怪兽×3
-- 这张卡用只以手卡和自己场上的怪兽各1只以上为素材的融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用魔法卡的效果融合召唤的场合才能发动。自己抽出从手卡作为融合素材的数量，把从场上作为融合素材的数量的对方场上的卡破坏。
-- ②：只要自己墓地有「融合」存在，对方不能把这张卡作为效果的对象。
function c11321089.initial_effect(c)
	-- 为卡片注册融合素材所需的特定卡片代码列表，用于标记该卡效果中提及了特定卡片
	aux.AddCodeList(c,24094653)
	c:EnableReviveLimit()
	-- 设置融合召唤的处理函数，要求使用3个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c11321089.ffilter,3,false)
	-- ①：这张卡用魔法卡的效果融合召唤的场合才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MATERIAL_LIMIT)
	e0:SetValue(c11321089.matlimit)
	c:RegisterEffect(e0)
	-- ②：只要自己墓地有「融合」存在，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11321089.splimit)
	c:RegisterEffect(e1)
	-- 自己抽出从手卡作为融合素材的数量，把从场上作为融合素材的数量的对方场上的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11321089,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11321089)
	e2:SetCondition(c11321089.drcon)
	e2:SetTarget(c11321089.drtg)
	e2:SetOperation(c11321089.drop)
	c:RegisterEffect(e2)
	-- 记录融合素材中手牌和场上的数量，用于后续效果处理
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c11321089.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 当自己墓地存在「融合」时，对方不能将此卡作为效果对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c11321089.indcon)
	-- 设置效果值为过滤函数，用于判断是否成为对方效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 融合素材筛选函数，用于判断是否满足融合召唤的条件
function c11321089.ffilter(c,fc,sub,mg,sg)
	if not sg then return true end
	local chkloc=LOCATION_HAND
	if c:IsOnField() then chkloc=LOCATION_ONFIELD end
	return not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode())
		-- 确保融合素材中手牌和场上的怪兽数量符合要求
		and (not c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) or #sg<2 or sg:IsExists(aux.NOT(Card.IsLocation),1,c,chkloc))
end
-- 限制融合召唤时的素材来源，只能是手牌或自己场上的怪兽
function c11321089.matlimit(e,c,fc,st)
	if st~=SUMMON_TYPE_FUSION then return true end
	return c:IsLocation(LOCATION_HAND) or c:IsControler(fc:GetControler()) and c:IsOnField()
end
-- 限制特殊召唤的条件，必须是融合召唤方式
function c11321089.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
-- 判断是否为魔法卡的效果融合召唤
function c11321089.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_SPELL) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置效果的目标，包括抽卡和破坏对方场上卡
function c11321089.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dr,des=e:GetLabel()
	-- 检查是否满足抽卡和破坏对方场上卡的条件
	if chk==0 then return dr and des and Duel.IsPlayerCanDraw(tp,dr)
		-- 检查对方场上的卡是否满足破坏数量要求
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=des end
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,dr,tp,0)
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标参数
	Duel.SetTargetParam(dr)
	-- 获取对方场上的所有卡作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行抽卡和破坏效果的函数
function c11321089.drop(e,tp,eg,ep,ev,re,r,rp)
	local dr,des=e:GetLabel()
	-- 执行抽卡操作，若成功则继续处理破坏效果
	if Duel.Draw(tp,dr,REASON_EFFECT)>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方场上的指定数量卡进行破坏
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,des,des,nil)
		if #g==des then
			-- 显示选中的卡作为破坏对象
			Duel.HintSelection(g)
			-- 执行破坏操作
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 记录融合素材数量的函数
function c11321089.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	local mg2=mg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	e:GetLabelObject():SetLabel(#mg1,#mg2)
end
-- 判断是否满足效果触发条件的函数
function c11321089.indcon(e)
	-- 检查自己墓地是否存在「融合」
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,24094653)
end
