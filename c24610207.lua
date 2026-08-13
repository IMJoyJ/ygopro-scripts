--アステル・ドローン
-- 效果：
-- ①：把这张卡在超量召唤使用的场合，可以把这张卡的等级当作5星使用。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
function c24610207.initial_effect(c)
	-- ①：把这张卡在超量召唤使用的场合，可以把这张卡的等级当作5星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c24610207.xyzlv)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c24610207.efcon)
	e2:SetOperation(c24610207.efop)
	c:RegisterEffect(e2)
end
-- 将画星宝宝作为超量素材时的等级设定为5星与其原本等级的组合值，使这张卡可作为5星或原本等级用于超量召唤。
function c24610207.xyzlv(e,c,rc)
	return 0x50000+e:GetHandler():GetLevel()
end
-- 判定这张卡被用作超量召唤的素材（reason包含REASON_XYZ），才继续执行给超量召唤出的怪兽附加效果的处理。
function c24610207.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 当画星宝宝作为超量素材被使用后，获取以此素材超量召唤出的怪兽rc，为rc注册“超量召唤成功时抽1张”的诱发效果；若rc不是效果怪兽，则先将其变为效果怪兽以能持有该效果。
function c24610207.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(24610207,0))  --"抽1张卡（画星宝宝）"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c24610207.drcon)
	e1:SetTarget(c24610207.drtg)
	e1:SetOperation(c24610207.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判定获得此效果的怪兽是否通过超量召唤成功（召唤类型为SUMMON_TYPE_XYZ），只有超量召唤成功时才发动抽卡效果。
function c24610207.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 抽卡效果发动时的目标/发动准备处理：无选择对象，向对方玩家提示已发动此效果，将抽卡玩家设为效果发动者tp，抽卡数量设为1，并登记操作为抽1张卡（CATEGORY_DRAW）。
function c24610207.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家（1-tp）发送提示，展示画星宝宝的抽卡效果描述，表示选择了该效果发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁效果的对象玩家设置为效果发动者tp，即抽卡的玩家为tp。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本效果将执行抽卡（CATEGORY_DRAW），目标玩家为tp，处理参数为1（抽1张）；因抽卡数量已由参数确定，目标卡组设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时，从连锁信息中取得之前设置的对象玩家p和对象参数d（抽卡数量），令玩家p抽d张卡，抽卡原因记为REASON_EFFECT。
function c24610207.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别赋给p和d，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果（REASON_EFFECT）为原因抽d张卡，完成‘自己从卡组抽1张’的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
