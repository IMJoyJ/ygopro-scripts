--電池メン－ボタン型
-- 效果：
-- 反转：从自己卡组把1只「电池人-纽扣型」以外的4星以下的名字带有「电池人」的怪兽特殊召唤。此外，反转过的这张卡被战斗破坏送去墓地时，从自己卡组抽1张卡。
function c56839613.initial_effect(c)
	-- 反转：从自己卡组把1只「电池人-纽扣型」以外的4星以下的名字带有「电池人」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56839613,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c56839613.target)
	e1:SetOperation(c56839613.operation)
	c:RegisterEffect(e1)
	-- 反转过的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c56839613.flipop)
	c:RegisterEffect(e2)
	-- 此外，反转过的这张卡被战斗破坏送去墓地时，从自己卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56839613,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c56839613.drcon)
	e3:SetTarget(c56839613.drtg)
	e3:SetOperation(c56839613.drop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中卡名非「电池人-纽扣型」、4星以下且名字带有「电池人」的可以特殊召唤的怪兽
function c56839613.filter(c,e,tp)
	return not c:IsCode(56839613) and c:IsSetCard(0x28) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 反转效果的发动准备，设置特殊召唤的操作信息
function c56839613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 反转效果的处理：从卡组特殊召唤1只符合条件的「电池人」怪兽
function c56839613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c56839613.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 反转时的处理：给这张卡注册一个表示“已反转过”的Flag标记
function c56839613.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(56839613,RESET_EVENT+0x17a0000,0,0)
end
-- 抽卡效果的发动条件：自身在墓地、是被战斗破坏，且带有已反转过的Flag标记
function c56839613.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetFlagEffect(56839613)~=0
end
-- 抽卡效果的发动准备，设置抽卡的目标玩家、数量及操作信息
function c56839613.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果处理对象为自己（抽卡玩家）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理：让目标玩家抽指定数量的卡
function c56839613.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
