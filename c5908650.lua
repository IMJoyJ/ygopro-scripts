--幻奏の音姫ローリイット・フランソワ
-- 效果：
-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽的效果发动。
-- ①：1回合1次，以自己墓地1只天使族·光属性怪兽为对象才能发动。那只怪兽加入手卡。
function c5908650.initial_effect(c)
	-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽的效果发动。①：1回合1次，以自己墓地1只天使族·光属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5908650,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c5908650.thcost)
	e1:SetCondition(c5908650.thcon)
	e1:SetTarget(c5908650.thtg)
	e1:SetOperation(c5908650.thop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家在连锁中发动怪兽效果的情况
	Duel.AddCustomActivityCounter(5908650,ACTIVITY_CHAIN,c5908650.chainfilter)
end
-- 自定义活动计数器的过滤函数，用于筛选出非光属性怪兽效果的发动
function c5908650.chainfilter(re,tp,cid)
	-- 获取当前连锁发生时发动效果的卡片的属性
	local attr=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_ATTRIBUTE)
	return not (re:IsActiveType(TYPE_MONSTER) and attr&(ATTRIBUTE_ALL&~ATTRIBUTE_LIGHT)~=0)
end
-- 效果的发动Cost函数，用于检查并适用“不能把光属性以外的怪兽的效果发动”的限制
function c5908650.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查本回合玩家是否发动过非光属性怪兽的效果
	if chk==0 then return Duel.GetCustomActivityCount(5908650,tp,ACTIVITY_CHAIN)==0 end
	-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽的效果发动。①：1回合1次，以自己墓地1只天使族·光属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c5908650.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能把光属性以外的怪兽的效果发动”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果的发动条件函数，要求这张卡在场上且是光属性
function c5908650.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 限制效果的过滤函数，使玩家不能发动非光属性怪兽的效果
function c5908650.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_LIGHT)
end
-- 墓地目标怪兽的过滤函数，筛选出可以加入手卡的天使族·光属性怪兽
function c5908650.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果的发动准备（Target）函数，用于确认是否有合法的目标并进行选择
function c5908650.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c5908650.filter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的天使族·光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c5908650.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只天使族·光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c5908650.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果的操作分类为“加入手卡”，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理（Operation）函数，将选中的墓地怪兽加入手卡
function c5908650.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
