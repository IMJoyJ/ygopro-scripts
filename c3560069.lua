--レイテンシ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡因效果从自己墓地加入手卡的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤的这张卡作为连接素材送去墓地的场合才能发动。自己从卡组抽1张。
function c3560069.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡因效果从自己墓地加入手卡的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3560069,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,3560069)
	e1:SetCondition(c3560069.spcon)
	e1:SetTarget(c3560069.sptg)
	e1:SetOperation(c3560069.spop)
	c:RegisterEffect(e1)
end
-- 检查①效果的触发条件：此卡的加入手卡原因是效果（bit.band(r,REASON_EFFECT)~=0），且加入手卡前位于自己墓地（IsPreviousLocation(LOCATION_GRAVE)），并且此卡之前的控制者是发动玩家本人（IsPreviousControler(tp)），即“这张卡因效果从自己墓地加入手卡”。
function c3560069.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- ①效果的发动与目标合法性判定：在chk==0的检查阶段，确认己方主要怪兽区有空位，且此卡满足通常特殊召唤条件（不检查召唤条件/苏生限制），以此判断能否从手卡发动特殊召唤效果。
function c3560069.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在①效果发动合法性检查（chk==0）中，确认己方场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息：对象为这张卡，数量为1，类别为特殊召唤，供效果处理及被其他卡（如星尘龙、王家长眠之谷等）检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若这张卡仍与本次效果关联，则将其表侧表示特殊召唤到己方场上；若特殊召唤成功，则给这张卡注册②效果（作为连接素材送去墓地时抽1张），并设置重置条件为保留其在离场/去墓地后的效果（因为②效果需要在该卡作为连接素材送墓后发动）。
function c3560069.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡与当前发动的效果仍有关联（未因离场等重置联系），然后执行特殊召唤：以表侧表示通常特殊召唤到己方场上；若特殊召唤成功（返回值不为0），才继续注册后续效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡的①的效果特殊召唤的这张卡作为连接素材送去墓地的场合才能发动。自己从卡组抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(3560069,1))
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_BE_MATERIAL)
		e1:SetCountLimit(1,3560070)
		e1:SetCondition(c3560069.drcon)
		e1:SetTarget(c3560069.drtg)
		e1:SetOperation(c3560069.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的触发条件：这张卡当前位于墓地，且是因为作为连接召唤素材（r==REASON_LINK）而被送去墓地；由于②效果只在①效果特殊召唤成功后注册，因此必然满足“这张卡的①的效果特殊召唤的这张卡”这一前提。
function c3560069.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- ②效果的目标函数：进行可发动性检查，确认己方可以抽1张卡；随后将抽卡目标玩家设为自身，抽卡张数参数设为1，并设置抽卡类操作信息。
function c3560069.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在②效果发动合法性检查（chk==0）中，确认己方玩家当前能够抽1张卡（未受到不能抽卡的效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果目标玩家设置为己方（tp），表示抽卡行为影响的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果目标参数设置为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置本次连锁的抽卡操作信息：类别为抽卡，目标玩家为tp，预计抽1张；因抽卡对象无法预先指定为具体卡片，targets传nil，供效果处理及检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：从当前连锁信息中读取之前记录的目标玩家和抽卡张数，执行抽卡操作。
function c3560069.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和目标参数，分别赋值给p和d，用于决定谁抽几张卡。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成“自己从卡组抽1张”的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
