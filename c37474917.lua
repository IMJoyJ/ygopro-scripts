--カタパルト・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 把自己场上存在的1只名字带有「废品」的怪兽解放发动。给与对方基本分解放的怪兽的原本攻击力数值的伤害。这个效果1回合只能使用1次。
function c37474917.initial_effect(c)
	-- 为该卡添加同调召唤手续，素材要求为「调整＋调整以外的怪兽1只以上」，且不额外限制调整或调整以外怪兽的卡名、种族等条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 把自己场上存在的1只名字带有「废品」的怪兽解放发动。给与对方基本分解放的怪兽的原本攻击力数值的伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37474917,0))  --"伤害"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c37474917.cost)
	e1:SetTarget(c37474917.target)
	e1:SetOperation(c37474917.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：选择并解放自己场上1只名字带有「废品」的怪兽，同时将该怪兽的原本攻击力数值记录下来用于后续伤害计算。
function c37474917.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在至少1只可解放且卡名属于「废品」系列的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x43) end
	-- 让玩家从自己场上选择1只卡名属于「废品」系列的怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x43)
	local atk=sg:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选择的「废品」怪兽解放，作为效果发动的代价（以COST方式解放）。
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的目标设定：将对象玩家设为对方，伤害数值设为代价怪兽的原本攻击力，并登记操作信息以便伤害效果被正确识别。
function c37474917.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定效果的对象玩家为对方的玩家（1-tp），表示伤害将给予对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设定效果的对象参数为之前记录的解放怪兽的原本攻击力数值，该数值即为将要造成的伤害值。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记本次连锁的操作信息：该效果属于伤害效果，伤害对象为对方玩家，伤害数值为解放怪兽的原本攻击力；该信息用于其他卡的效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理：从连锁信息中取得目标玩家和伤害数值，并对该玩家造成对应的效果伤害。
function c37474917.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和目标参数，分别赋值给p和d，作为造成伤害的对象与数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给玩家p造成d点伤害，即把解放怪兽的原本攻击力数值伤害给与对方。
	Duel.Damage(p,d,REASON_EFFECT)
end
