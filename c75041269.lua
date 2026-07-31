--幽獄の時計塔
-- 效果：
-- 对方回合的准备阶段时，这张卡放置1个时计指示物。时计指示物合计有4个以上的场合，这张卡的控制者不会受到战斗伤害。放置有4个以上时计指示物的这张卡被破坏送去墓地时，从手卡·卡组特殊召唤1只「命运英雄 恐惧人」。
function c75041269.initial_effect(c)
	-- 注册包含「命运英雄」字段怪兽列表
	aux.AddSetNameMonsterList(c,0xc008)
	c:EnableCounterPermit(0x1b)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 初始化卡片效果：注册①对方准备阶段自动放置时计指示物效果（强制诱发）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75041269,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c75041269.ctcon)
	e2:SetOperation(c75041269.ctop)
	c:RegisterEffect(e2)
	-- 初始化卡片效果：注册②4个以上时计指示物时控制者战斗伤害抗性（永续效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c75041269.dcon)
	c:RegisterEffect(e3)
	-- 初始化卡片效果：注册离场前指示物数量检测效果（为破坏送墓特召效果记录状态）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c75041269.regop)
	c:RegisterEffect(e0)
	-- 初始化卡片效果：注册③放置4个以上指示物被破坏送墓时特殊召唤「命运英雄 恐惧人」效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75041269,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c75041269.spcon)
	e4:SetTarget(c75041269.sptg)
	e4:SetOperation(c75041269.spop)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
c75041269.mentioned_counter={
	[0x1b]=true,
}
-- 战斗伤害免疫条件检查：此卡放置的时计指示物数量达到4个以上
function c75041269.dcon(e)
	return e:GetHandler():GetCounter(0x1b)>=4
end
-- 指示物放置条件检查：当前为对方回合的准备阶段
function c75041269.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 放置指示物效果处理：给此卡放置1个时计指示物
function c75041269.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1b,1)
end
-- 离场前状态记录：若离开场地前时计指示物不少于4个，将Label设为1，否则设为0
function c75041269.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x1b)>=4 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 特殊召唤条件检查：因破坏送去墓地且离场前指示物不少于4个
function c75041269.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and e:GetLabelObject():GetLabel()==1
end
-- 特召怪兽过滤条件：卡名为「命运英雄 恐惧人」且可特殊召唤
function c75041269.spfilter(c,e,tp)
	return c:IsCode(40591390) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动准备：设置从手牌·卡组特召怪兽的操作信息
function c75041269.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从手牌或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果处理：从手牌·卡组选择1只「命运英雄 恐惧人」表侧表示特殊召唤
function c75041269.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件/处理检查：主怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组选择1只满足条件的「命运英雄 恐惧人」
	local g=Duel.SelectMatchingCard(tp,c75041269.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
