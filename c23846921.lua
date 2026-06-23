--アルカナフォースⅩⅩⅠ－THE WORLD
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：自己的结束阶段时可以把自己场上存在的2只怪兽送去墓地让下次的对方回合跳过。
-- ●里：对方的抽卡阶段时把对方墓地最上面1张卡加入对方手卡。
function c23846921.initial_effect(c)
	-- 为卡片注册一个在召唤·反转召唤·特殊召唤成功时强制进行硬币投掷的效果
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：自己的结束阶段时可以把自己场上存在的2只怪兽送去墓地让下次的对方回合跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23846921,1))  --"跳过对方回合"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c23846921.skipcon)
	e1:SetCost(c23846921.skipcost)
	e1:SetTarget(c23846921.skiptg)
	e1:SetOperation(c23846921.skipop)
	c:RegisterEffect(e1)
	-- ●里：对方的抽卡阶段时把对方墓地最上面1张卡加入对方手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23846921,2))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c23846921.thcon)
	e2:SetTarget(c23846921.thtg)
	e2:SetOperation(c23846921.thop)
	c:RegisterEffect(e2)
end
-- 判断是否为表效果（硬币投掷结果为正面）且当前为自己的结束阶段
function c23846921.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 支付效果代价：选择2只场上怪兽送去墓地
function c23846921.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件（场上至少有2只怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,nil) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的2只怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,2,nil)
	-- 将选中的怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置跳过回合效果的目标判定条件
function c23846921.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以发动跳过回合效果（对方未被跳过回合）
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
-- 执行跳过对方回合的效果
function c23846921.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册跳过对方回合的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将跳过回合效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为里效果（硬币投掷结果为反面）且当前为对方的抽卡阶段
function c23846921.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 设置回收效果的目标判定条件
function c23846921.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方墓地最上面的1张卡
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc then
		-- 设置连锁操作信息，指定要回收的卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	end
end
-- 执行回收效果
function c23846921.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地最上面的1张卡
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc then
		-- 将对方墓地最上面的卡加入对方手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向玩家确认对方手卡的卡
		Duel.ConfirmCards(tp,tc)
	end
end
