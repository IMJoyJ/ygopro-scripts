--デンジャラス・デストーイ・ナイトメアリー
-- 效果：
-- 「锋利小鬼」怪兽＋「毛绒动物」怪兽×2
-- ①：这张卡的攻击力在自己回合内上升自己墓地的天使族·恶魔族怪兽数量×300。
-- ②：融合召唤的这张卡战斗破坏怪兽时才能发动。把那只怪兽的等级数量的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽从卡组送去墓地。
-- ③：场上的这张卡为对象的对方的效果发动时，从额外卡组把1只「魔玩具」怪兽除外才能发动。那个效果无效。
function c58468105.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「锋利小鬼」怪兽＋「毛绒动物」怪兽×2
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc3),aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),2,2,true)
	-- ①：这张卡的攻击力在自己回合内上升自己墓地的天使族·恶魔族怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c58468105.value)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡战斗破坏怪兽时才能发动。把那只怪兽的等级数量的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c58468105.tgcon)
	e2:SetTarget(c58468105.tgtg)
	e2:SetOperation(c58468105.tgop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡为对象的对方的效果发动时，从额外卡组把1只「魔玩具」怪兽除外才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c58468105.discon)
	e3:SetCost(c58468105.discost)
	e3:SetTarget(c58468105.distg)
	e3:SetOperation(c58468105.disop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地的天使族·恶魔族怪兽
function c58468105.atkfilter(c)
	return c:IsRace(RACE_FAIRY+RACE_FIEND)
end
-- 计算自己回合内这张卡因自身效果上升的攻击力数值
function c58468105.value(e,c)
	local tp=c:GetControler()
	-- 若当前不是自己的回合，则攻击力不上升
	if Duel.GetTurnPlayer()~=tp then return 0 end
	-- 返回自己墓地的天使族·恶魔族怪兽数量乘以300的数值
	return Duel.GetMatchingGroupCount(c58468105.atkfilter,tp,LOCATION_GRAVE,0,nil)*300
end
-- 检测是否为融合召唤的这张卡战斗破坏对方怪兽
function c58468105.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否为融合召唤，且是否在战斗中破坏了对方怪兽
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤卡组中可以送去墓地的「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽
function c58468105.tgfilter(c)
	return c:IsSetCard(0xc3,0xa9,0xad) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 战斗破坏怪兽时效果的启动检测与效果处理声明
function c58468105.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local lv=bc:GetLevel()
	e:SetLabel(lv)
	-- 在发动阶段，检查卡组中是否存在被破坏怪兽等级数量的符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58468105.tgfilter,tp,LOCATION_DECK,lv,lv,nil) end
	-- 声明该效果的操作信息为将卡组的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 战斗破坏怪兽时效果的具体处理：从卡组选择被破坏怪兽等级数量的符合条件的怪兽送去墓地
function c58468105.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local lv=e:GetLabel()
	-- 让玩家从卡组选择与被破坏怪兽等级相同数量的「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c58468105.tgfilter,tp,LOCATION_DECK,0,lv,lv,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤额外卡组中可以作为发动代价除外的「魔玩具」怪兽
function c58468105.costfilter(c)
	return c:IsSetCard(0xad) and c:IsAbleToRemoveAsCost()
end
-- 无效效果的发动代价处理：从额外卡组将1只「魔玩具」怪兽除外
function c58468105.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查额外卡组是否存在可以作为代价除外的「魔玩具」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58468105.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从额外卡组选择1只「魔玩具」怪兽
	local g=Duel.SelectMatchingCard(tp,c58468105.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的「魔玩具」怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检测是否为对方发动了以场上的这张卡为对象的效果
function c58468105.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前连锁中被指定为对象的卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断被指定的对象中是否包含这张卡，且该效果是否可以被无效
	return tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
-- 无效效果的启动检测与效果处理声明
function c58468105.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 声明该效果的操作信息为使该效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的具体处理：使该效果无效
function c58468105.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
