--魔聖騎士皇ランスロット
-- 效果：
-- 调整＋调整以外的「圣骑士」怪兽1只以上
-- ①：「魔圣骑士皇 兰斯洛特」在自己场上只能有1只表侧表示存在。
-- ②：这张卡同调召唤成功时才能发动。从卡组选1张「圣剑」装备魔法卡给这张卡装备。
-- ③：这张卡战斗破坏怪兽送去墓地的战斗阶段结束时才能发动。从卡组把1张「圣骑士」卡或者「圣剑」卡加入手卡。
function c83519853.initial_effect(c)
	c:SetUniqueOnField(1,0,83519853)
	-- 设置同调召唤手续：调整＋调整以外的「圣骑士」怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x107a),1)
	c:EnableReviveLimit()
	-- ②：这张卡同调召唤成功时才能发动。从卡组选1张「圣剑」装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83519853,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c83519853.condition)
	e1:SetTarget(c83519853.target)
	e1:SetOperation(c83519853.operation)
	c:RegisterEffect(e1)
	-- ③：这张卡战斗破坏怪兽送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c83519853.regcon)
	e2:SetOperation(c83519853.regop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏怪兽送去墓地的战斗阶段结束时才能发动。从卡组把1张「圣骑士」卡或者「圣剑」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83519853,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c83519853.thcon)
	e3:SetTarget(c83519853.thtg)
	e3:SetOperation(c83519853.thop)
	c:RegisterEffect(e3)
end
-- 检查此卡是否是通过同调召唤特殊召唤的
function c83519853.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可以装备给此卡的「圣剑」装备魔法卡
function c83519853.filter(c,ec)
	return c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果②（同调召唤成功时装备卡组「圣剑」）的发动准备与合法性检查
function c83519853.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张可以装备给此卡的「圣剑」装备魔法卡
		and Duel.IsExistingMatchingCard(c83519853.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- 效果②（同调召唤成功时装备卡组「圣剑」）的处理：从卡组选1张「圣剑」装备魔法卡装备给此卡
function c83519853.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔陷区是否已无空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「圣剑」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c83519853.filter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的装备魔法卡装备给此卡
		Duel.Equip(tp,tc,c)
	end
end
-- 检查此卡是否在战斗中破坏了怪兽并将其送去墓地
function c83519853.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 给此卡注册一个持续到回合结束的标志（Flag），用于记录其在战斗中破坏了怪兽
function c83519853.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(83519853,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查此卡是否带有战斗破坏怪兽的标志（Flag）
function c83519853.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(83519853)~=0
end
-- 过滤卡组中可以加入手牌的「圣骑士」卡片或「圣剑」卡片
function c83519853.thfilter(c)
	return c:IsSetCard(0x107a,0x207a) and c:IsAbleToHand()
end
-- 效果③（战斗阶段结束时检索）的发动准备与操作信息设置
function c83519853.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「圣骑士」卡片或「圣剑」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c83519853.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③（战斗阶段结束时检索）的处理：从卡组将1张「圣骑士」卡或「圣剑」卡加入手卡
function c83519853.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「圣骑士」卡或「圣剑」卡
	local g=Duel.SelectMatchingCard(tp,c83519853.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
