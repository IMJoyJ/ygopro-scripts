--サクリボー
-- 效果：
-- ①：这张卡被解放的场合发动。自己从卡组抽1张。
-- ②：自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c50185950.initial_effect(c)
	-- ①：这张卡被解放的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50185950,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetTarget(c50185950.drtg)
	e1:SetOperation(c50185950.drop)
	c:RegisterEffect(e1)
	-- ②：自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c50185950.reptg)
	e2:SetValue(c50185950.repval)
	e2:SetOperation(c50185950.repop)
	c:RegisterEffect(e2)
end
-- 效果①的目标/发动条件函数：在发动前判定（chk==0）时无条件返回 true，表示可以发动；随后将抽卡玩家设为效果发动者 tp，抽卡数量设为 1，并向系统登记本效果为抽卡（CATEGORY_DRAW）操作，供连锁判定等使用。
function c50185950.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为 tp，即把“抽卡者”设定为发动这个效果的一方，呼应“自己从卡组抽1张”中的“自己”。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为 1，表示这次抽卡要抽 1 张，作为后续 Duel.Draw 的张数依据。
	Duel.SetTargetParam(1)
	-- 向系统登记本次效果的操作信息：类别为抽卡（CATEGORY_DRAW），不指定具体对象卡，目标玩家为 tp（抽卡者），参数为 1（抽卡数）；此信息用于连锁响应和规则判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的处理函数：从当前连锁信息中取出之前设定的对象玩家 p 和抽卡数 d，然后让玩家 p 以效果原因抽 d 张卡，实际完成“自己从卡组抽1张”。
function c50185950.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时取得 CHAININFO_TARGET_PLAYER 和 CHAININFO_TARGET_PARAM，分别赋给 p 和 d，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家 p 从卡组抽 d 张卡，reason 记为 REASON_EFFECT（效果原因），完成抽卡动作。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选条件：c 必须是己方（tp）控制、位于主要怪兽区、因战斗被破坏（REASON_BATTLE），且不是因代替效果而被破坏（不含 REASON_REPLACE），用以识别“自己怪兽被战斗破坏”的正确场合。
function c50185950.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动条件判定：当场上存在满足 filter 的己方怪兽被战斗破坏，并且墓地中的这张卡可以被除外时，返回 true；随后用 SelectEffectYesNo 询问玩家是否发动代替破坏效果。
function c50185950.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c50185950.filter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	-- 弹出是否发动的确认选择，让玩家 tp 选择是否将墓地中的这张卡除外来替代破坏，96 为对应的提示文本编号。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- EFFECT_DESTROY_REPLACE 的值函数：判断要被破坏的怪兽 c 是否满足被这次代替保护的条件，即复用 filter 检查 c 是否为己方怪兽、位于主要怪兽区、因战斗破坏且非代替破坏。
function c50185950.repval(e,c)
	return c50185950.filter(c,e:GetHandlerPlayer())
end
-- ②效果实际执行的操作：当玩家确认发动后，将墓地中的这张卡（e:GetHandler()）除外，以代替本应被战斗破坏的己方怪兽，使其不因战斗破坏而送墓。
function c50185950.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地中的这张卡以表侧表示除外，原因记为 REASON_EFFECT + REASON_REPLACE，表示这是通过效果进行的代替除外操作。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
