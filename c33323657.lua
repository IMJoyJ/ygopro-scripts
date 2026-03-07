--サイコ・ソウル
-- 效果：
-- 把自己场上存在的1只念动力族怪兽解放发动。自己回复解放怪兽的等级×300的数值的基本分。
function c33323657.initial_effect(c)
	-- 效果原文：把自己场上存在的1只念动力族怪兽解放发动。自己回复解放怪兽的等级×300的数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c33323657.reccost)
	e1:SetTarget(c33323657.rectg)
	e1:SetOperation(c33323657.recop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的念动力族怪兽（等级大于0）
function c33323657.filter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_PSYCHO)
end
-- 检查并选择1只满足条件的念动力族怪兽进行解放，记录其等级
function c33323657.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查场上是否存在满足条件的念动力族怪兽用于解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33323657.filter,1,nil) end
	-- 从场上选择1只满足条件的念动力族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c33323657.filter,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选中的怪兽以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 设置连锁处理时的目标玩家和回复LP数值
function c33323657.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()~=0 end
	-- 设置连锁处理时的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理时的目标参数为解放怪兽等级乘以300
	Duel.SetTargetParam(e:GetLabel()*300)
	-- 设置连锁操作信息为回复效果，目标玩家和回复数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel()*300)
	e:SetLabel(0)
end
-- 执行连锁效果，使目标玩家回复指定数值的基本分
function c33323657.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（回复LP数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
