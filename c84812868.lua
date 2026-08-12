--月光白兎
-- 效果：
-- ①：这张卡召唤成功时，以「月光白兔」以外的自己墓地1只「月光」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：1回合1次，以最多有这张卡以外的自己场上的「月光」卡数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
function c84812868.initial_effect(c)
	-- ①：这张卡召唤成功时，以「月光白兔」以外的自己墓地1只「月光」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84812868,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c84812868.sptg)
	e1:SetOperation(c84812868.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以最多有这张卡以外的自己场上的「月光」卡数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c84812868.thtg)
	e2:SetOperation(c84812868.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地「月光白兔」以外的可以守备表示特殊召唤的「月光」怪兽
function c84812868.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and not c:IsCode(84812868) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标选择
function c84812868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84812868.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「月光」怪兽
		and Duel.IsExistingTarget(c84812868.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「月光」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84812868.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（将选择的怪兽特殊召唤）
function c84812868.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：自己场上表侧表示的「月光」卡
function c84812868.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf)
end
-- 过滤条件：对方场上的魔法·陷阱卡且能回到手卡
function c84812868.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择
function c84812868.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c84812868.filter2(chkc) end
	-- 检查自己场上是否存在至少1张这张卡以外的「月光」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c84812868.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张魔法·陷阱卡
		and Duel.IsExistingTarget(c84812868.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 计算这张卡以外的自己场上的「月光」卡数量，作为可选对象的最大数量
	local ct=Duel.GetMatchingGroupCount(c84812868.filter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多有对应数量的对方场上的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c84812868.filter2,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理信息为将选择的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果②的处理（将选择的卡送回手牌）
function c84812868.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
