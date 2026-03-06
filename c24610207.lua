--アステル・ドローン
-- 效果：
-- ①：把这张卡在超量召唤使用的场合，可以把这张卡的等级当作5星使用。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
function c24610207.initial_effect(c)
	-- 效果原文内容：①：把这张卡在超量召唤使用的场合，可以把这张卡的等级当作5星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c24610207.xyzlv)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c24610207.efcon)
	e2:SetOperation(c24610207.efop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：将该卡的等级设定为5星（0x50000）加上原本等级
function c24610207.xyzlv(e,c,rc)
	return 0x50000+e:GetHandler():GetLevel()
end
-- 规则层面操作：判断是否因超量召唤而成为素材
function c24610207.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 规则层面操作：为作为超量素材的怪兽注册诱发效果，使其在超量召唤成功时发动抽卡效果
function c24610207.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 效果原文内容：●这次超量召唤成功的场合发动。自己从卡组抽1张。
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
		-- 规则层面操作：若作为超量素材的怪兽没有TYPE_EFFECT，则为其添加TYPE_EFFECT类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 规则层面操作：判断怪兽是否为超量召唤 summoned
function c24610207.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 规则层面操作：设置抽卡效果的目标玩家和抽卡数量
function c24610207.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：向对方提示“对方选择了：抽1张卡（画星宝宝）”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面操作：设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 规则层面操作：设置连锁的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：执行抽卡效果，从卡组抽1张卡
function c24610207.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：让指定玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
