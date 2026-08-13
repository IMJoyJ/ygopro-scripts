--BF－孤高のシルバー・ウィンド
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤时，以场上最多2只表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不能进行战斗阶段）。持有比这张卡的攻击力低的守备力的作为对象的怪兽破坏。
-- ②：只要这张卡在怪兽区域存在，对方回合只有1次，自己的「黑羽」怪兽不会被战斗破坏。
function c33236860.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只「黑羽」调整怪兽＋调整以外的怪兽2只以上作为素材进行同调召唤。
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
-- e1的发动条件：这张卡以同调召唤方式特殊召唤成功时（召唤类型为同调召唤）才可发动。
function c33236860.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 发动代价：先确认自己本回合尚未进入战斗阶段；随后给自己设置一个持续到回合结束的‘不能进入战斗阶段’的誓约效果。
function c33236860.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价的合法性检查：本回合自己进入战斗阶段的次数为0，即尚未进行过战斗阶段时，才能允许发动该效果。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- ①：这张卡同调召唤时，以场上最多2只表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不能进行战斗阶段）。持有比这张卡的攻击力低的守备力的作为对象的怪兽破坏。②：只要这张卡在怪兽区域存在，对方回合只有1次，自己的「黑羽」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新建的‘不能进入战斗阶段’效果e1以誓约方式注册给当前玩家tp，使其本回合生效。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：对象必须是表侧表示怪兽，且其守备力低于这张卡当前的攻击力（守备力≤攻击力-1）。
function c33236860.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
-- 取对象效果的目标处理：从双方怪兽区域选择1~2只表侧表示且守备力低于本卡攻击力的怪兽作为对象，并设置破坏的操作信息。
function c33236860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c33236860.filter(chkc,c:GetAttack()) end
	-- 发动合法性检查：场上是否存在至少1只可被选择的符合条件的对象怪兽（表侧且守备力低于这张卡攻击力）。
	if chk==0 then return Duel.IsExistingTarget(c33236860.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 向玩家显示‘请选择要破坏的卡’的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由发动玩家从双方怪兽区域选择1~2只符合条件的表侧表示怪兽作为效果对象（同时将这些卡记录为连锁对象）。
	local g=Duel.SelectTarget(tp,c33236860.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil,c:GetAttack())
	-- 设置连锁操作信息：本次处理将破坏已选择的对象组g中的全部卡，破坏数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的再筛选：对象怪兽必须仍与效果相关联、表侧表示，且守备力仍低于这张卡当前攻击力。
function c33236860.desfilter(c,e,atk)
	return c:IsFaceup() and c:IsRelateToEffect(e) and c:IsDefenseBelow(atk-1)
end
-- 效果处理：这张卡仍与效果关联时，从连锁对象中筛选出仍符合条件的怪兽，将它们全部效果破坏；若本卡离场则处理不执行。
function c33236860.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取出当前连锁中记录的对象卡组（即发动时选择并设置的目标怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c33236860.desfilter,nil,e,c:GetAttack())
	-- 将筛选后的怪兽以效果破坏（破坏原因为效果，REASON_EFFECT）。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的适用条件：当前回合必须是对方回合（当前回合玩家不是这张卡的控制者）。
function c33236860.indcon(e)
	-- 判断当前回合玩家是否等于这张卡控制者的对手（玩家编号0/1互为对手），满足时即为对方回合。
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
-- ②效果的保护目标判定：受到保护的怪兽必须是「黑羽」（0x33）怪兽。
function c33236860.indtg(e,c)
	return c:IsSetCard(0x33)
end
-- ②效果的守护次数值判定：仅当受到的破坏原因为战斗破坏时才视为满足‘不会被战斗破坏’的次数条件（消耗1次机会）。
function c33236860.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
