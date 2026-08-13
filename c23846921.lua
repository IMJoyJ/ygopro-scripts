--アルカナフォースⅩⅩⅠ－THE WORLD
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：自己的结束阶段时可以把自己场上存在的2只怪兽送去墓地让下次的对方回合跳过。
-- ●里：对方的抽卡阶段时把对方墓地最上面1张卡加入对方手卡。
function c23846921.initial_effect(c)
	-- 为这张卡注册秘仪之力通用的抛硬币判定，在通常召唤·反转召唤·特殊召唤成功时强制抛硬币，并根据正反设置标志（表=1/里=0）。
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- 自己结束阶段，把自己场上2只怪兽送去墓地才能发动。下次的对方回合跳过。
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
	-- 对方抽卡阶段发动。对方墓地最上面的卡加入对方手卡。
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
-- 判定当前是否为本方结束阶段（ep==tp），且此卡在硬币中为表（标志为1），满足表效果才能发动。
function c23846921.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 表效果的代价处理：检查并支付把自己场上2只怪兽送去墓地的代价，选择符合条件的怪兽后将其以代价形式送入墓地。
function c23846921.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少2只可以作为代价送去墓地的怪兽，若不足则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,nil) end
	-- 弹出“请选择要送去墓地的卡”的选卡提示，引导玩家选择要作为代价的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择正好2只可以作为代价的怪兽，作为发动表效果的祭品。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,2,nil)
	-- 将选择的2只怪兽以“代价”（REASON_COST）形式送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动条件检查：确认对方当前没有受到“跳过回合”效果影响；若对方已被跳过回合，则此效果不能发动。
function c23846921.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方没有获得“跳过回合”效果，避免让对方连续跳过回合；若已存在则不可发动。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
-- 创建并注册一个影响对方玩家的“跳过回合”永续效果，使其下一次对方回合被跳过，效果持续到对方回合结束时重置。
function c23846921.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己结束阶段，把自己场上2只怪兽送去墓地才能发动。下次的对方回合跳过。对方抽卡阶段发动。对方墓地最上面的卡加入对方手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将生成的“跳过对方回合”效果正式注册到场上，控制者为发动效果的本方，作用目标是对方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判定当前是对方的抽卡阶段（ep不为本方）且此卡在硬币中为里（标志为0），满足里效果的强制发动条件。
function c23846921.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 里效果的发动/目标处理：取对方墓地最上面那张卡作为将要加入对方手卡的对象，并登记操作信息。
function c23846921.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方墓地中位于最上方（即最后进入墓地）的那张卡。
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc then
		-- 将这张卡登记为本次效果要送回手卡的对象，用于连锁判定和效果处理。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	end
end
-- 处理里效果：将对方墓地最上面的卡加入对方手卡，并向本方玩家展示那张卡。
function c23846921.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次从对方墓地取得最上面那张卡，用于实际移动。
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc then
		-- 将这张卡以效果原因（REASON_EFFECT）加入对方手卡，完成“回收”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让本方玩家确认已加入对方手卡的那张卡，以完成效果处理及信息公开。
		Duel.ConfirmCards(tp,tc)
	end
end
