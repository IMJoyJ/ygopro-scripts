--エクストクス・ハイドラ
-- 效果：
-- 从额外卡组特殊召唤的自己场上的怪兽×2只以上
-- ①：只要这张卡在怪兽区域存在，和作为这张卡的融合素材的怪兽种类（融合·同调·超量·灵摆·连接）相同种类的对方场上的怪兽攻击力下降原本攻击力数值。
-- ②：这张卡给与对方1000以上的战斗伤害时才能发动。那次伤害每有1000，自己从卡组抽1张。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制并添加融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2到127个满足条件的怪兽作为融合素材
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
	-- ②：这张卡给与对方1000以上的战斗伤害时才能发动。那次伤害每有1000，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 以融合怪兽为融合素材
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
-- 过滤融合素材怪兽，要求其从额外卡组特殊召唤且在场上
function s.mfilter(c,fc)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsOnField() and c:IsControler(fc:GetControler())
end
-- 检查怪兽类型是否匹配
function s.checkfilter(c,rtype)
	return c:IsType(rtype)
end
-- 判断该卡是否为融合召唤成功
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 记录融合素材的怪兽种类，并注册对应标志效果
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
-- 判断目标怪兽是否与融合素材种类相同，决定是否适用攻击力下降效果
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
-- 设置攻击力下降值为怪兽原本攻击力的负值
function s.atkval(e,c)
	return -c:GetBaseAttack()
end
-- 判断是否为对方造成的战斗伤害且伤害值大于等于1000
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and ev>=1000
end
-- 设置抽卡效果的目标玩家和抽卡数量
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=math.floor(ev/1000)
	-- 检查玩家是否可以抽指定数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,val) end
	-- 设置连锁处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数（抽卡数量）
	Duel.SetTargetParam(val)
	-- 设置连锁操作信息，包含抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,val)
end
-- 处理抽卡效果的执行函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		-- 执行抽卡操作，原因设为效果抽卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
