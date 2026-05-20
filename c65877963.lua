--魔神儀－カリスライム
-- 效果：
-- 「魔神仪的祝诞」降临。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，从卡组把1只「魔神仪」怪兽特殊召唤。发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合，结束阶段让自己失去2500基本分。
-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「魔神仪」卡送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c65877963.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，从卡组把1只「魔神仪」怪兽特殊召唤。发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合，结束阶段让自己失去2500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65877963)
	e1:SetCost(c65877963.spcost)
	e1:SetTarget(c65877963.sptg)
	e1:SetOperation(c65877963.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「魔神仪」卡送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,65877963)
	e2:SetCost(c65877963.descost)
	e2:SetTarget(c65877963.destg)
	e2:SetOperation(c65877963.desop)
	c:RegisterEffect(e2)
end
-- 检查手牌中的这张卡是否未公开（用于确认是否满足展示手牌的发动条件）
function c65877963.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中可以特殊召唤的「魔神仪」怪兽
function c65877963.spfilter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位、手牌数量以及卡组中是否存在可特召的「魔神仪」怪兽）
function c65877963.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位，且手牌数量大于0（因为需要丢弃1张手牌）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查卡组中是否存在可以特殊召唤的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c65877963.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：丢弃1张手牌，从卡组特殊召唤1只「魔神仪」怪兽，并注册用于检测仪式召唤成功与否以及结束阶段扣血的延迟效果
function c65877963.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家选择并丢弃1张手牌，若丢弃成功且怪兽区域仍有空位
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送选择要特殊召唤的卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足特召条件的「魔神仪」怪兽
		local g=Duel.SelectMatchingCard(tp,c65877963.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自身场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c65877963.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，用于监听并记录本回合自己是否成功特殊召唤过仪式怪兽
	Duel.RegisterEffect(e1,tp)
	-- 结束阶段让自己失去2500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c65877963.damcon)
	e2:SetOperation(c65877963.damop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	-- 注册全局效果，在回合结束阶段触发扣血判定
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出由自身特殊召唤的仪式怪兽
function c65877963.regfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsType(TYPE_RITUAL)
end
-- 监听特殊召唤成功事件，若特召了仪式怪兽，则将标志效果的Label设为1
function c65877963.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c65877963.regfilter,1,nil,tp) then
		e:SetLabel(1)
	end
end
-- 检查扣血条件：若本回合未成功特殊召唤过仪式怪兽（即Label不等于1）
function c65877963.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=1
end
-- 扣血效果处理：使自身失去2500基本分
function c65877963.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家的生命值减少2500点（失去2500基本分）
	Duel.SetLP(tp,Duel.GetLP(tp)-2500)
end
-- 过滤手牌或场上表侧表示的、可以作为Cost送去墓地的「魔神仪」卡片
function c65877963.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x117) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动Cost处理：从手牌或场上表侧表示的卡中选择1张「魔神仪」卡送去墓地
function c65877963.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在可作为Cost送去墓地的「魔神仪」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c65877963.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择要送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌或场上表侧表示的卡中选择1张「魔神仪」卡片
	local g=Duel.SelectMatchingCard(tp,c65877963.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡作为发动Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的目标选择与连锁信息设置（选择对方场上1只怪兽为对象）
function c65877963.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择要破坏的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏选定对象的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏选中的对方怪兽
function c65877963.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
