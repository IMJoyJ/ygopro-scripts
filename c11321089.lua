--ガーディアン・キマイラ
-- 效果：
-- 卡名不同的怪兽×3
-- 这张卡用只以手卡和自己场上的怪兽各1只以上为素材的融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用魔法卡的效果融合召唤的场合才能发动。自己抽出从手卡作为融合素材的数量，把从场上作为融合素材的数量的对方场上的卡破坏。
-- ②：只要自己墓地有「融合」存在，对方不能把这张卡作为效果的对象。
function c11321089.initial_effect(c)
	-- 在卡片c上登记卡号24094653（即「融合」），表示这张卡效果文本中记载了该卡名，供后续涉及‘记载有卡名’或墓地存在「融合」的判断使用。
	aux.AddCodeList(c,24094653)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用3只满足c11321089.ffilter条件的怪兽作为融合素材；该过滤函数会保证素材卡名不同，并配合素材限制使手卡素材和场上素材都至少各有1只。
	aux.AddFusionProcFunRep(c,c11321089.ffilter,3,false)
	-- 用只以手卡和自己场上的怪兽各1只以上为素材的融合召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MATERIAL_LIMIT)
	e0:SetValue(c11321089.matlimit)
	c:RegisterEffect(e0)
	-- 才能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11321089.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用魔法卡的效果融合召唤的场合才能发动。自己抽出从手卡作为融合素材的数量，把从场上作为融合素材的数量的对方场上的卡破坏。
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
	-- 自己抽出从手卡作为融合素材的数量，把从场上作为融合素材的数量的对方场上的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c11321089.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：只要自己墓地有「融合」存在，对方不能把这张卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c11321089.indcon)
	-- 设置免疫效果的值函数为aux.tgoval，使对方玩家的效果不能以这张卡为对象，从而实现②的‘对方不能作为效果对象’效果。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数：候选素材之间不能拥有相同的融合素材名（即卡名不能重复），并且在已选素材中通过区域校验确保最终素材不会全部来自手卡或全部来自场上，以满足‘手卡和自己场上的怪兽各1只以上’。
function c11321089.ffilter(c,fc,sub,mg,sg)
	if not sg then return true end
	local chkloc=LOCATION_HAND
	if c:IsOnField() then chkloc=LOCATION_ONFIELD end
	return not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode())
		-- 如果候选素材不在手牌或场上则先放行（由素材限制效果再处理）；否则当已选素材达到2只以上时，要求已选素材中存在至少1只与候选素材所在区域（手牌或场上）不同的卡，从而保证两种区域的素材都至少有1只。
		and (not c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) or #sg<2 or sg:IsExists(aux.NOT(Card.IsLocation),1,c,chkloc))
end
-- 素材限制函数：若非融合召唤不检查；若是融合召唤，素材只能是手卡中的怪兽或由这张融合怪兽的控制者控制的场上的怪兽。
function c11321089.matlimit(e,c,fc,st)
	if st~=SUMMON_TYPE_FUSION then return true end
	return c:IsLocation(LOCATION_HAND) or c:IsControler(fc:GetControler()) and c:IsOnField()
end
-- 特殊召唤条件限制：若这张卡在额外卡组，则必须通过融合召唤才能特殊召唤；若不在额外卡组（例如从墓地特殊召唤）则不受此限制。
function c11321089.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
-- ①效果的发动条件：这张卡因魔法卡的效果而融合召唤成功（re为引发该次融合召唤的效果且其类型为魔法卡）。
function c11321089.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_SPELL) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的发动合法性判断：读取预先记录的手卡素材数dr和场上素材数des；在检查时需确认dr、des均有效，自己能够抽dr张卡，且对方场上的卡片数量不少于des。
function c11321089.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dr,des=e:GetLabel()
	-- 检查时先确认已经记录了素材数量，并且当前玩家可以抽dr张卡。
	if chk==0 then return dr and des and Duel.IsPlayerCanDraw(tp,dr)
		-- 同时检查对方场上的卡片数量不少于要破坏的数量des，满足才允许发动。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=des end
	-- 设置操作信息：声明本次连锁包含抽卡处理，抽卡数为dr，抽卡玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,dr,tp,0)
	-- 将当前连锁处理的对象玩家设置为tp，表示抽卡对象为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为dr，用于记录抽卡数量。
	Duel.SetTargetParam(dr)
	-- 获取对方场上的所有卡（使用aux.TRUE过滤全部），作为破坏效果的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：声明本次连锁包含破坏处理，候选破坏对象为对方场上的所有卡，数量信息设为1用于效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：首先执行抽dr张卡；若抽卡成功，则从对方场上选择des张卡（不取对象）并将其破坏。
function c11321089.drop(e,tp,eg,ep,ev,re,r,rp)
	local dr,des=e:GetLabel()
	-- 实际执行抽卡，只有抽卡成功（张数大于0）时才继续后续破坏处理。
	if Duel.Draw(tp,dr,REASON_EFFECT)>0 then
		-- 给玩家tp弹出“请选择要破坏的卡”的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 不取对象地从对方场上选择des张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,des,des,nil)
		if #g==des then
			-- 显示被选中的卡片并记录为本次效果选择的卡片，用于动画与连锁信息展示。
			Duel.HintSelection(g)
			-- 以效果原因破坏选中的卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 素材数量统计函数：融合召唤时统计作为素材的手卡怪兽数量和场上怪兽数量，并将这两个数值写入①效果e2的Label中，供①效果处理时决定抽卡数和破坏数。
function c11321089.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	local mg2=mg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	e:GetLabelObject():SetLabel(#mg1,#mg2)
end
-- ②效果的适用条件：这张卡的控制者墓地存在卡名「融合」（卡号24094653）。
function c11321089.indcon(e)
	-- 检查自己墓地是否存在至少1张卡号为24094653的「融合」卡。
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,24094653)
end
