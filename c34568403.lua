--アルカナフォースⅦ－THE CHARIOT
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：这张卡战斗破坏对方怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
-- ●里：这张卡的控制权转移给对方。
function c34568403.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。●里：这张卡的控制权转移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34568403,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	-- 设置该效果的Target为秘仪之力通用的抛硬币判定函数：在召唤成功时声明将进行硬币判定，并允许该效果进入连锁。
	e1:SetTarget(aux.ArcanaCoinTarget)
	e1:SetOperation(c34568403.coinop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ●表：这张卡战斗破坏对方怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34568403,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c34568403.spcon)
	e4:SetTarget(c34568403.sptg)
	e4:SetOperation(c34568403.spop)
	c:RegisterEffect(e4)
end
-- 召唤成功时硬币效果的处理：若光之结界适用则由玩家直接选择表/里作为硬币结果，否则投掷1枚硬币；随后将结果以秘仪之力硬币标志记录在该卡上，若结果为里则把这张卡的控制权转移给对方。
function c34568403.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=0
	local toss=false
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 在光之结界适用时，让玩家在“表”和“里”选项中选择，并将其转换为内部硬币值（表=1，里=0）。
		res=1-Duel.SelectOption(tp,60,61)
	else
		-- 投掷1枚硬币，结果为1表示表（正面），0表示里（反面）。
		res=Duel.TossCoin(tp,1)
		toss=true
	end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if toss then
		c:RegisterFlagEffect(FLAG_ID_REVERSAL_OF_FATE,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	c:RegisterFlagEffect(FLAG_ID_ARCANA_COIN,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,res,63-res)
	if res==0 then
		-- 当硬币结果为里时，将这张卡的控制权转移给对方玩家。
		Duel.GetControl(c,1-tp)
	end
end
-- 表效果的发动条件：这张卡的秘仪之力硬币标志为1（硬币结果为表），且这张卡正在与对方怪兽进行战斗（即战斗破坏对方怪兽）。
function c34568403.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 特殊召唤的Target函数：获取此卡战斗破坏的对方怪兽作为候选，在发动时检查该怪兽是否能被特殊召唤，并根据其所在位置（墓地、除外区或额外牌组）确认有足够的特殊召唤区域。
function c34568403.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若对象在墓地，或在除外区且为表侧表示，则要求自己场上存在可用的主要怪兽区空格。
		and ((tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED) and tc:IsFaceup()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若对象在额外牌组且为表侧表示，则要求存在可供额外卡组怪兽特殊召唤的空位（额外怪兽区等）。
			or tc:IsLocation(LOCATION_EXTRA) and tc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0) end
	-- 将战斗破坏的对方怪兽设为这个效果的对象，使其与当前连锁关联。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：声明本效果将把对象怪兽特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果处理：获取战斗破坏的对方怪兽，若仍与效果关联，则将其特殊召唤到自己场上。
function c34568403.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
