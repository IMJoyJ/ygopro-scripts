--星騎士 セイクリッド・カドケウス
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合，以自己墓地的「星骑士」、「星圣」卡各最多1张为对象才能发动。那些卡加入手卡。
-- ②：从手卡·卡组把1只「星骑士」、「星圣」怪兽除外，把这张卡1个超量素材取除才能发动。除外的怪兽的自身的召唤成功时发动的效果适用。
function c58858807.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：4星怪兽2只以上进行叠放
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	-- 开启全局标记，用于支持超量素材数量限制相关的检测
	Duel.EnableGlobalFlag(GLOBALFLAG_XMAT_COUNT_LIMIT)
	-- ①：这张卡超量召唤的场合，以自己墓地的「星骑士」、「星圣」卡各最多1张为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58858807,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,58858807)
	e1:SetCondition(c58858807.thcon)
	e1:SetTarget(c58858807.thtg)
	e1:SetOperation(c58858807.thop)
	c:RegisterEffect(e1)
	-- ②：从手卡·卡组把1只「星骑士」、「星圣」怪兽除外，把这张卡1个超量素材取除才能发动。除外的怪兽的自身的召唤成功时发动的效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58858807,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58858808)
	e2:SetTarget(c58858807.copytg)
	e2:SetOperation(c58858807.copyop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡超量召唤成功
function c58858807.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤自己墓地中可以作为效果对象且能加入手牌的「星骑士」或「星圣」卡
function c58858807.thfilter(c,e)
	return c:IsSetCard(0x9c,0x53) and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 检查选择的卡片组是否符合数量为1，或者为「星骑士」和「星圣」卡各1张的条件
function c58858807.fselect(g)
	if #g==1 then return true end
	-- 检查选中的两张卡是否分别属于「星骑士」和「星圣」系列
	return aux.gfcheck(g,Card.IsSetCard,0x9c,0x53)
end
-- 效果①的发动准备与对象选择：选择墓地中最多各1张的「星骑士」和「星圣」卡作为对象
function c58858807.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58858807.thfilter(chkc,e) end
	-- 获取自己墓地中所有符合条件的「星骑士」和「星圣」卡
	local g=Duel.GetMatchingGroup(c58858807.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:SelectSubGroup(tp,c58858807.fselect,false,1,2)
	-- 将玩家选择的卡片设为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息为将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的卡加入手牌
function c58858807.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍与该连锁相关的对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	if #tg==0 then return end
	-- 将这些对象卡片加入持有者的手牌
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
-- 过滤手牌或卡组中可以作为代价除外，且拥有合法的“召唤成功时发动的效果”的「星骑士」或「星圣」怪兽
function c58858807.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x9c,0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()) then return false end
	local te=c.star_knight_summon_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 效果②的发动准备与代价处理：取除1个超量素材，并除外1只手牌或卡组的「星骑士」或「星圣」怪兽，同时模拟该怪兽效果的发动检测
function c58858807.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
			-- 检查手牌或卡组中是否存在至少1只符合复制效果条件的「星骑士」或「星圣」怪兽
			and Duel.IsExistingMatchingCard(c58858807.efffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌或卡组中选择1只符合复制效果条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c58858807.efffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local tc=g:GetFirst()
	-- 清除当前连锁的对象，防止被复制的效果错误地继承或干扰原本的对象设定
	Duel.ClearTargetCard()
	e:SetLabelObject(tc)
	local te=tc.star_knight_summon_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，因为具体适用的效果在发动时无法确定，需在效果处理时动态适用
	Duel.ClearOperationInfo(0)
end
-- 效果②的效果处理：适用被除外怪兽的召唤成功时的效果
function c58858807.copyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local te=tc.star_knight_summon_effect
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
