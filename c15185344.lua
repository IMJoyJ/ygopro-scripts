--燦冠乗騎シックラヴィー
local s,id,o=GetID()
local COUNTER_CROWN=0x77
-- 初始化XYZ召唤手续并注册触发效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,3,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_CROWN)
	-- 此卡不能作为超量素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- 战斗破坏时发动，提升攻击力或送入额外卡组并抽三张卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x77]=true,
}
-- 判断叠放怪兽是否为表侧表示、种族为兽族且攻击力不超过2000
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttackBelow(2000)
end
-- 检查是否已使用过此效果（通过标识效果）
function s.xyzop(e,tp,chk)
	-- 若未使用过此效果则返回true
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册一个在结束阶段重置的标识效果，防止重复使用
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断此卡是否为表侧表示且参与了战斗
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsRelateToBattle()
end
-- 根据计数器数量返回对应的效果分类
function s.predcat(ct)
	if ct==1 or ct==2 then
		return CATEGORY_ATKCHANGE
	elseif ct==3 then
		return CATEGORY_TOEXTRA+CATEGORY_DRAW
	else
		return 0
	end
end
-- 设置连锁操作信息，包括攻击变化、送入额外卡组和抽卡
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local ct=c:GetCounter(COUNTER_CROWN)+1
	local cat=s.predcat(ct)
	e:SetCategory(cat)
	if cat&CATEGORY_ATKCHANGE~=0 then
		-- 设置攻击变化的操作信息
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0)
	elseif cat&CATEGORY_TOEXTRA~=0 then
		-- 设置送入额外卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
		-- 设置目标玩家为当前玩家
		Duel.SetTargetPlayer(tp)
		-- 设置目标参数为3（表示抽三张卡）
		Duel.SetTargetParam(3)
		-- 设置抽卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	end
end
-- 处理连锁效果，根据计数器数量执行不同操作
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsFaceup()) then return end
	if not c:AddCounter(COUNTER_CROWN,1) then return end
	local ct=c:GetCounter(COUNTER_CROWN)
	if ct==1 then
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		s.atkup(c,400)
	elseif ct==2 then
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		s.atkup(c,600)
	elseif ct==3 then
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		-- 获取连锁的目标玩家和参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 将此卡送入卡组并洗牌，若成功且在额外卡组则执行抽卡
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
			-- 让指定玩家抽指定数量的卡
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
-- 创建一个提升攻击力的效果
function s.atkup(c,val)
	-- 提升此卡的攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
