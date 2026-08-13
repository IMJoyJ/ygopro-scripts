--ドラグニティ・ドラフト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「龙骑兵团」怪兽为对象。那个场合，那只怪兽加入手卡。
-- ②：这张卡在魔法与陷阱区域存在，原本等级是5星以上的自己的「龙骑兵团」怪兽攻击的场合，那只怪兽直到伤害步骤结束时不受对方的效果影响。
function c52962804.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以自己墓地1只4星以下的「龙骑兵团」怪兽为对象。那个场合，那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,52962804+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c52962804.target)
	c:RegisterEffect(e1)
	-- ②：这张卡在魔法与陷阱区域存在，原本等级是5星以上的自己的「龙骑兵团」怪兽攻击的场合，那只怪兽直到伤害步骤结束时不受对方的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52962804.immtg)
	e2:SetValue(c52962804.efilter)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡片等级在4以下、属于「龙骑兵团」字段、且可以被加入手卡（用于选择墓地对象）。
function c52962804.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x29) and c:IsAbleToHand()
end
-- 发动时的处理：先检查是否选择墓地怪兽为对象；若存在可选对象且玩家选择是，则将效果设为取对象回手牌类别，指定操作函数，选择1张符合条件的墓地怪兽为对象并写入操作信息；否则清除类别、对象标志和操作函数（仅作为通常发动处理）。
function c52962804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52962804.thfilter(chkc) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1只满足4星以下·「龙骑兵团」·可加入手卡且能成为效果对象的怪兽。
	if Duel.IsExistingTarget(c52962804.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否要以自己墓地怪兽为对象发动；如果选择是，则之后选择对象，否则按不取对象处理。
		and Duel.SelectYesNo(tp,aux.Stringid(52962804,0)) then  --"是否以自己墓地怪兽为对象发动？"
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c52962804.activate)
		-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己墓地选择1只满足4星以下·「龙骑兵团」·可加入手卡的怪兽作为效果对象（取对象）。
		local g=Duel.SelectTarget(tp,c52962804.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息：将选择的对象加入手牌，数量为1，持有者为当前玩家。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 效果处理时的操作：取得发动时选择的对象，若该对象仍与效果关联，则将其加入持有者的手卡。
function c52962804.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中已选择的效果对象卡（通常只有1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送去其持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 免疫效果的适用对象筛选：判断怪兽是否为原本等级5星以上且属于「龙骑兵团」字段，并且是当前正在攻击的怪兽。
function c52962804.immtg(e,c)
	-- 返回真条件：怪兽的原本等级≥5、具有「龙骑兵团」字段、且就是当前攻击的怪兽。
	return c:GetOriginalLevel()>=5 and c:IsSetCard(0x29) and Duel.GetAttacker()==c
end
-- 免疫效果的过滤条件：仅当要免疫的效果的持有者不是这张卡的控制者（即来自对方的效果）时，才使对象不受该效果影响。
function c52962804.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
