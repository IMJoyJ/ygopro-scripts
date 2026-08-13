--古神クトグア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。场上的4阶超量怪兽全部回到持有者的额外卡组。
-- ②：这张卡为素材的融合召唤成功的场合发动。自己从卡组抽1张。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
function c12948099.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以“调整＋调整以外的怪兽1只以上”为素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。场上的4阶超量怪兽全部回到持有者的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12948099,0))  --"回到持有者的额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12948099.tdcon)
	e1:SetTarget(c12948099.tdtg)
	e1:SetOperation(c12948099.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡为素材的融合召唤成功的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12948099,1))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c12948099.drcon)
	e2:SetTarget(c12948099.drtg)
	e2:SetOperation(c12948099.drop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c12948099.efcon)
	e3:SetOperation(c12948099.efop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：此卡是作为同调召唤而特殊召唤成功（召唤类型为同调召唤）。
function c12948099.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选条件：超量怪兽、阶级4、且能回到额外卡组，用于选择场上的4阶超量怪兽。
function c12948099.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsAbleToExtra()
end
-- ①效果的发动时点检查与对象设定：确认场上存在符合条件的4阶超量怪兽，并将它们全部设为“返回额外卡组”的操作对象。
function c12948099.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1张满足filter（4阶超量怪兽且能回额外卡组）的卡片，作为①效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得当前场上所有满足filter的4阶超量怪兽，用于后续操作信息。
	local g=Duel.GetMatchingGroup(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设定操作信息：类别为返回额外卡组，目标为g中的怪兽，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- ①效果处理：再次取得场上满足filter的4阶超量怪兽，数量大于0时将其全部返回持有者的额外卡组。
function c12948099.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上满足filter的4阶超量怪兽，确保处理时仍存在这些卡。
	local g=Duel.GetMatchingGroup(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将g中的怪兽全部送往持有者的额外卡组（即弹回额外卡组）。
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- ②效果的触发条件：这张卡作为融合召唤的素材被使用（reason为REASON_FUSION）。
function c12948099.drcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION
end
-- ②效果的发动处理：不取对象；设定目标玩家为自己、抽卡数1，并设置抽卡类别的操作信息。
function c12948099.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设为效果发动者自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的目标参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置抽卡类别操作信息：目标玩家为自己，抽卡数1，用于效果处理与相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：取得之前保存的目标玩家和抽卡数，让目标玩家抽相应数量的卡。
function c12948099.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的目标玩家与目标参数（抽牌玩家和抽牌数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，实际执行‘自己从卡组抽1张’。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③辅助效果的触发条件：这张卡作为超量召唤的素材被使用（reason为REASON_XYZ）。
function c12948099.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- ③辅助效果处理：找出以这张卡为素材进行超量召唤的那只怪兽，为它赋予“这个超量召唤成功时自己抽1张”的诱发效果；若该怪兽没有效果怪兽类型，则额外赋予其效果怪兽类型。
function c12948099.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(12948099,2))  --"抽1张卡（古神 克图格亚）"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12948099.drcon2)
	e1:SetTarget(c12948099.drtg2)
	e1:SetOperation(c12948099.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这次超量召唤成功的场合发动。自己从卡组抽1张。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 被赋予的抽卡效果的发动条件：该怪兽是作为超量召唤而特殊召唤成功（召唤类型为超量召唤）。
function c12948099.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 被赋予的抽卡效果的发动处理：不取对象；提示对方选择了该效果；设定目标玩家为自己、抽卡数1，并设置抽卡类别操作信息。
function c12948099.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家发送提示“对方选择了该效果”，并显示对应描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将被赋予效果的目标玩家设为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将被赋予效果的目标参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置抽卡类别操作信息：目标玩家为自己，抽卡数1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
