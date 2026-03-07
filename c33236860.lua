--BF－孤高のシルバー・ウィンド
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤时，以场上最多2只表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不能进行战斗阶段）。持有比这张卡的攻击力低的守备力的作为对象的怪兽破坏。
-- ②：只要这张卡在怪兽区域存在，对方回合只有1次，自己的「黑羽」怪兽不会被战斗破坏。
function c33236860.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（黑羽卡组）+2只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以场上最多2只表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不能进行战斗阶段）。持有比这张卡的攻击力低的守备力的作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33236860,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c33236860.descon)
	e1:SetCost(c33236860.descost)
	e1:SetTarget(c33236860.destg)
	e1:SetOperation(c33236860.desop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方回合只有1次，自己的「黑羽」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c33236860.indcon)
	e2:SetTarget(c33236860.indtg)
	e2:SetValue(c33236860.valcon)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：此卡必须是同调召唤成功
function c33236860.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动的费用：检查此玩家在本回合是否已进入过战斗阶段，若未进入则可发动
function c33236860.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此玩家在本回合是否已进入过战斗阶段，若未进入则返回true
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 创建一个使此玩家不能进入战斗阶段的效果并注册
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且守备力低于指定值
function c33236860.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
-- 设置效果的目标：选择场上1~2只满足条件的怪兽作为对象
function c33236860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c33236860.filter(chkc,c:GetAttack()) end
	-- 检查是否场上存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c33236860.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1~2只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c33236860.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil,c:GetAttack())
	-- 设置效果操作信息：确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤函数：判断目标怪兽是否为表侧表示、与效果相关且守备力低于指定值
function c33236860.desfilter(c,e,atk)
	return c:IsFaceup() and c:IsRelateToEffect(e) and c:IsDefenseBelow(atk-1)
end
-- 效果处理：将满足条件的怪兽破坏
function c33236860.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中已选定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c33236860.desfilter,nil,e,c:GetAttack())
	-- 将满足条件的怪兽组进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 效果发动的条件：当前回合玩家为对方
function c33236860.indcon(e)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
-- 效果目标过滤函数：判断目标怪兽是否为黑羽卡组
function c33236860.indtg(e,c)
	return c:IsSetCard(0x33)
end
-- 效果值函数：判断破坏原因是否为战斗
function c33236860.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
