--エクストクス・ハイドラ
-- 效果：
-- 从额外卡组特殊召唤的自己场上的怪兽×2只以上
-- ①：只要这张卡在怪兽区域存在，和作为这张卡的融合素材的怪兽种类（融合·同调·超量·灵摆·连接）相同种类的对方场上的怪兽攻击力下降原本攻击力数值。
-- ②：这张卡给与对方1000以上的战斗伤害时才能发动。那次伤害每有1000，自己从卡组抽1张。
local s,id,o=GetID()
-- 为外毒多头蛇进行效果初始化：允许融合召唤并设定融合素材条件（从额外卡组特殊召唤到自己场上的怪兽×2只以上）；注册①的永续降低攻击力效果、特殊召唤成功时登记融合素材种类的辅助效果、②战斗伤害抽卡效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材需为2只以上（最多127只）满足s.mfilter条件的怪兽（即从额外卡组特殊召唤、在自己场上且控制者与融合召唤控制者相同的怪兽）。
	aux.AddFusionProcFunRep2(c,s.mfilter,2,127,true)
	-- ①：只要这张卡在怪兽区域存在，和作为这张卡的融合素材的怪兽种类（融合·同调·超量·灵摆·连接）相同种类的对方场上的怪兽攻击力下降原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ①中“作为这张卡的融合素材的怪兽种类（融合·同调·超量·灵摆·连接）”的登记处理：在融合召唤成功时根据素材实际种类打上对应标记，供后续攻击力下降效果判定使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方1000以上的战斗伤害时才能发动。那次伤害每有1000，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 融合素材筛选函数：判断怪兽是否是从额外卡组特殊召唤、当前在场上、且控制者与融合召唤的这张卡（fc）的控制者相同。
function s.mfilter(c,fc)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsOnField() and c:IsControler(fc:GetControler())
end
-- 辅助过滤器：判断怪兽是否具有指定类型rtype（融合/同调/超量/灵摆/连接），用于检查素材种类。
function s.checkfilter(c,rtype)
	return c:IsType(rtype)
end
-- 素材种类登记效果的发动条件：本卡是以融合召唤方式特殊召唤成功时才执行登记。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤成功后的处理：取得融合素材卡组，若素材中存在融合/同调/超量/灵摆/连接怪兽，则为自身分别打上对应标记（id、id+o、id+o*2、id+o*3、id+o*4），并显示对应的客户端提示文本。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g==0 then return end
	if g:IsExists(s.checkfilter,1,nil,TYPE_FUSION) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"以融合怪兽为融合素材"
	end
	if g:IsExists(s.checkfilter,1,nil,TYPE_SYNCHRO) then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"以同调怪兽为融合素材"
	end
	if g:IsExists(s.checkfilter,1,nil,TYPE_XYZ) then
		c:RegisterFlagEffect(id+o*2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"以超量怪兽为融合素材"
	end
	if g:IsExists(s.checkfilter,1,nil,TYPE_PENDULUM) then
		c:RegisterFlagEffect(id+o*3,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"以灵摆怪兽为融合素材"
	end
	if g:IsExists(s.checkfilter,1,nil,TYPE_LINK) then
		c:RegisterFlagEffect(id+o*4,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"以连接怪兽为融合素材"
	end
end
-- 攻击力降低效果的目标筛选：只有当这张卡登记过对应素材种类标记，且对方场上的表侧表示怪兽属于该种类时，该怪兽才会成为攻击力下降对象。
function s.atktg(e,c)
	if not c:IsFaceup() then return false end
	local ec=e:GetHandler()
	local b1=ec:GetFlagEffect(id)>0 and c:IsType(TYPE_FUSION)
	local b2=ec:GetFlagEffect(id+o)>0 and c:IsType(TYPE_SYNCHRO)
	local b3=ec:GetFlagEffect(id+o*2)>0 and c:IsType(TYPE_XYZ)
	local b4=ec:GetFlagEffect(id+o*3)>0 and c:IsType(TYPE_PENDULUM)
	local b5=ec:GetFlagEffect(id+o*4)>0 and c:IsType(TYPE_LINK)
	return b1 or b2 or b3 or b4 or b5
end
-- 攻击力降低数值：返回怪兽的原本攻击力的负值，即攻击力下降其原本攻击力数值。
function s.atkval(e,c)
	return -c:GetBaseAttack()
end
-- 抽卡效果的发动条件：战斗伤害的承受方是对方（ep≠tp），且战斗伤害数值至少为1000。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and ev>=1000
end
-- 抽卡效果的目标设定：计算可抽张数为伤害值除以1000向下取整；在发动检查时确认自己能否抽相应数量；然后设置对象玩家为自己、参数为抽卡张数，并声明抽卡操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=math.floor(ev/1000)
	-- 效果发动合法性检查：若为chk==0阶段，必须自己能够抽val张卡才能发动该效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,val) end
	-- 设置该连锁的对象玩家为自己（即抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 设置该连锁的对象参数为要抽的卡数val。
	Duel.SetTargetParam(val)
	-- 设置操作信息：该效果分类为抽卡，处理时由自己抽val张卡，目标卡组不确定所以targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,val)
end
-- 抽卡效果处理：从连锁信息中取出对象玩家和抽卡张数，若张数大于0则执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中保存的对象玩家p和抽卡张数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
