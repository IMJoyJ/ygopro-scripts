--サイコ・ソウル
-- 效果：
-- 把自己场上存在的1只念动力族怪兽解放发动。自己回复解放怪兽的等级×300的数值的基本分。
function c33323657.initial_effect(c)
	-- 把自己场上存在的1只念动力族怪兽解放发动。自己回复解放怪兽的等级×300的数值的基本分。
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
-- 过滤条件：等级大于0且种族为念动力族的怪兽。
function c33323657.filter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_PSYCHO)
end
-- 费用处理：检测并选择1只可解放的念动力族怪兽，将其等级记录到效果标签后解放作为代价。
function c33323657.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 费用检测：确认自己场上存在至少1只可解放且满足条件的念动力族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33323657.filter,1,nil) end
	-- 选择1只满足条件的念动力族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c33323657.filter,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选择的那只怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 目标处理：设定回复对象为自己和回复数值，登记操作信息，并重置标签。
function c33323657.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()~=0 end
	-- 将这次效果的目标玩家设定为发动者自己。
	Duel.SetTargetPlayer(tp)
	-- 将目标参数设定为解放怪兽的等级×300，即回复数值。
	Duel.SetTargetParam(e:GetLabel()*300)
	-- 登记操作信息：本次为回复LP效果，预计回复数值为等级×300。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel()*300)
	e:SetLabel(0)
end
-- 效果处理：取得之前设定的目标玩家和回复数值，执行LP回复。
function c33323657.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出目标玩家和回复参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家回复对应数值的LP，原因记为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
