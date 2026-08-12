--リィラップ
-- 效果：
-- 这个卡名的效果在同一连锁上只能发动1次。
-- ①：1回合1次，自己从墓地把怪兽特殊召唤的场合才能发动。对方失去1000基本分，自己回复500基本分。
local s,id,o=GetID()
-- 注册卡片发动效果（e0）以及在自己从墓地特殊召唤怪兽时触发的诱发效果（e1）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的效果在同一连锁上只能发动1次。①：1回合1次，自己从墓地把怪兽特殊召唤的场合才能发动。对方失去1000基本分，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.lpcon)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查怪兽是否由自己从墓地特殊召唤
function s.filter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsSummonPlayer(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 发动条件：检查当前特殊召唤的怪兽中是否存在满足过滤条件的怪兽
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
-- 效果发动：检测同一连锁内是否已发动过该效果，注册连锁结束重置的标记，并设置回复生命值的操作信息
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测当前玩家在同一连锁内是否尚未发动过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册一个在连锁结束时重置的标识，用于限制同一连锁只能发动1次
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置当前连锁的操作信息：玩家回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：使对方失去1000基本分，若对方基本分确实减少，则自己回复500基本分
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方当前的生命值
	local lp=Duel.GetLP(1-tp)
	-- 设置对方的生命值为当前值减少1000（使对方失去1000基本分）
	Duel.SetLP(1-tp,lp-1000)
	-- 若对方生命值成功减少，则自己回复500基本分
	if Duel.GetLP(1-tp)<lp then Duel.Recover(tp,500,REASON_EFFECT) end
end
