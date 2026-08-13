--魔弾の悪魔 ザミエル
-- 效果：
-- 这张卡可以把1只「魔弹」怪兽解放表侧表示上级召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：对方结束阶段才能发动。自己从卡组抽出这个回合这张卡表侧表示存在期间自己发动的「魔弹」魔法·陷阱卡的数量。
function c30907810.initial_effect(c)
	-- 这张卡可以把1只「魔弹」怪兽解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30907810,0))  --"把1只「魔弹」怪兽解放表侧表示上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c30907810.otcon)
	e1:SetOperation(c30907810.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30907810,2))  --"适用「魔弹恶魔 萨米尔」的效果来发动"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_MZONE)
	-- 设置效果适用对象的筛选函数：仅当手卡中的卡为「魔弹」系列卡时，才被允许从手卡发动。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetValue(32841045)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e4)
	-- ②：对方结束阶段才能发动。自己从卡组抽出这个回合这张卡表侧表示存在期间自己发动的「魔弹」魔法·陷阱卡的数量。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetDescription(aux.Stringid(30907810,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,30907810)
	e5:SetCondition(c30907810.drcon)
	e5:SetTarget(c30907810.drtg)
	e5:SetOperation(c30907810.drop)
	c:RegisterEffect(e5)
	-- 这个回合这张卡表侧表示存在期间自己发动的「魔弹」魔法·陷阱卡的数量
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetLabelObject(e5)
	e6:SetOperation(c30907810.regop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_CHAIN_NEGATED)
	e7:SetOperation(c30907810.regop2)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e8:SetOperation(c30907810.clearop)
	c:RegisterEffect(e8)
end
-- 过滤可作为上级召唤解放素材的「魔弹」怪兽：属于0x108系列，且（是自己控制的怪兽，或是表侧表示怪兽）。
function c30907810.otfilter(c,tp)
	return c:IsSetCard(0x108) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则效果的可发动条件：这张卡等级至少为7，所需祭品数不超过1，且存在至少1只符合条件的「魔弹」解放素材。
function c30907810.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方怪兽区域中可作为解放素材的「魔弹」怪兽集合，用于后续检查祭品是否足够。
	local mg=Duel.GetMatchingGroup(c30907810.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定是否满足上级召唤条件：等级≥7、祭品数量要求≤1、且存在符合条件的「魔弹」怪兽可供解放。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤手续：从符合条件的「魔弹」怪兽中选择1只作为祭品，解放它并完成召唤素材处理。
function c30907810.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方怪兽区域中可作为解放素材的「魔弹」怪兽集合，供玩家选择。
	local mg=Duel.GetMatchingGroup(c30907810.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从符合条件的「魔弹」怪兽中选择1只作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品怪兽解放作为素材，完成上级召唤的解放处理。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 当自己发动「魔弹」魔法·陷阱卡时，将计数标签加1，累计本回合发动次数。
function c30907810.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+1)
	end
end
-- 若「魔弹」魔法·陷阱卡的发动被无效，将计数标签减1（最低为0），修正实际成功发动的数量。
function c30907810.regop2(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		if val==0 then val=1 end
		e:GetLabelObject():SetLabel(val-1)
	end
end
-- 在抽卡阶段开始时将计数标签清零，开始统计新回合的发动数量。
function c30907810.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- ②效果的发动条件：当前为对方回合（当前回合玩家不是这张卡的控制者）。
function c30907810.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即满足只能在对方结束阶段发动的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果发动时的目标处理：检查抽卡数量合法，将对象玩家设为自己并设置抽卡操作信息。
function c30907810.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabel()
	-- 发动合法性检查：要求计数大于0且自己可以抽对应数量的卡。
	if chk==0 then return d>0 and Duel.IsPlayerCanDraw(tp,d) end
	-- 将本效果的对象玩家设置为自己（这张卡的控制者），表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：本效果将让对象玩家抽 d 张卡，类别为抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- ②效果处理：如果这张卡仍在场上且效果有效，则让对象玩家根据记录的数量抽卡。
function c30907810.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取效果处理时确定的对象玩家（本卡控制者），作为抽卡玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=e:GetLabel()
	if d>0 then
		-- 让对象玩家从卡组抽 d 张卡，原因为效果抽卡。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
