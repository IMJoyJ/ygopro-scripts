--燦冠乗騎シックラヴィー
local s,id,o=GetID()
local COUNTER_CROWN=0x77
-- 为c添加XYZ召唤手续，使用满足条件s.ovfilter的等级3的2只怪兽进行叠放；同时设置效果外文本描述aux.Stringid(id,0)和叠放操作函数s.xyzop。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,3,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_CROWN)
	-- 此卡不能作为超量素材（永续效果）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- 战斗破坏时发动，根据计数器数量改变攻击力或回额外卡组并抽卡的触发式效果
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
-- XYZ召唤时的怪兽筛选条件：表侧表示、兽族、攻击低于2000的怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttackBelow(2000)
end
-- XYZ召唤操作函数：检查是否已注册标识效果（chk==0），若未注册则创建全局环境下的OATH类型标识效果，阶段结束时重置。
function s.xyzop(e,tp,chk)
	-- 判断当前玩家是否已为该卡号id注册了FlagEffect标识效果的计数是否为0。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家tp注册一个全局环境下、类型为RESET_PHASE+PHASE_END的EFFECT_FLAG_OATH标识效果，数量为1。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 战斗破坏时的发动条件：怪兽表侧表示且与战斗相关（即被战斗破坏）。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsRelateToBattle()
end
-- 根据计数器数量决定操作分类：ct=1或2时为攻击力改变；ct=3时额外卡组+抽卡组合。
function s.predcat(ct)
	if ct==1 or ct==2 then
		return CATEGORY_ATKCHANGE
	elseif ct==3 then
		return CATEGORY_TOEXTRA+CATEGORY_DRAW
	else
		return 0
	end
end
-- 目标处理函数：获取当前怪兽，确定最终操作分类cat并设置到效果上；若包含ATKCHANGE则设定对象为该怪兽及数量1；若包含TOEXTRA则同样设对象为怪兽，同时创建DRAW操作的玩家和参数（3张）。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local ct=c:GetCounter(COUNTER_CROWN)+1
	local cat=s.predcat(ct)
	e:SetCategory(cat)
	if cat&CATEGORY_ATKCHANGE~=0 then
		-- 设置连锁0的操作信息为攻击力改变类别，目标卡为c，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0)
	elseif cat&CATEGORY_TOEXTRA~=0 then
		-- 设置连锁0的操作信息为回额外卡组类别，目标卡为c，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
		-- 将当前处理的连锁对象玩家设置为tp（怪兽持有者）。
		Duel.SetTargetPlayer(tp)
		-- 将当前处理的连锁对象参数设置为3（抽卡数量）。
		Duel.SetTargetParam(3)
		-- 设置连锁0的DRAW操作：不取对象、预计处理0张但实际由后续逻辑决定，目标玩家为tp，数量为3。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	end
end
-- 效果处理函数：若怪兽仍在场上且表侧则继续；先增加计数器+1；根据最终计数器数量分情况处理（ct=1/2时改变攻击力，ct=3时回额外卡组并抽卡）。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsFaceup()) then return end
	if not c:AddCounter(COUNTER_CROWN,1) then return end
	local ct=c:GetCounter(COUNTER_CROWN)
	if ct==1 then
		-- 错时点中断当前效果，使后续操作视为不同时处理。
		Duel.BreakEffect()
		s.atkup(c,400)
	elseif ct==2 then
		-- 同id 17：错时点中断当前效果。
		Duel.BreakEffect()
		s.atkup(c,600)
	elseif ct==3 then
		-- 同id 17：错时点中断当前效果。
		Duel.BreakEffect()
		-- 获取连锁0的目标玩家和参数（用于后续的抽卡操作）。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 若怪兽成功回额外卡组且位于额外卡组，则触发抽卡逻辑。
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
			-- 让玩家p以REASON_EFFECT原因抽取d张卡。
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
-- 攻击力改变辅助函数：创建单效果、类型为EFFECT_TYPE_SINGLE、代码为UPDATE_ATTACK、值为val（增加的攻击力）、重置条件为标准事件+标准阶段结束。
function s.atkup(c,val)
	-- 战斗破坏时发动，根据计数器数量给予怪兽相应攻击力的永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
