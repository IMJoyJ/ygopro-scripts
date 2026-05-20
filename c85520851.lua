--超伝導恐獣
-- 效果：
-- ①：1回合1次，把自己场上1只怪兽解放才能发动。给与对方1000伤害。这个效果发动的回合，这张卡不能攻击宣言。
function c85520851.initial_effect(c)
	-- ①：1回合1次，把自己场上1只怪兽解放才能发动。给与对方1000伤害。这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85520851,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c85520851.cost)
	e1:SetTarget(c85520851.target)
	e1:SetOperation(c85520851.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：检查自身本回合是否未宣言攻击、场上是否有可解放的怪兽，并选择1只怪兽解放，同时给自身添加本回合不能攻击宣言的限制
function c85520851.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查（chk==0）时，确认这张卡在本回合没有进行过攻击宣言，且自己场上存在至少1只可以解放的怪兽
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 and Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 让玩家从自己场上选择1只可解放的怪兽
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(sg,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果的目标处理：设置伤害的对象玩家为对方，伤害数值为1000，并向系统注册造成伤害的操作信息
function c85520851.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设定为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害值）设定为1000
	Duel.SetTargetParam(1000)
	-- 向系统注册当前连锁的操作信息，分类为伤害，对象为对方玩家，数值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果的实际处理：获取之前设定的目标玩家和伤害数值，并对该玩家造成相应的效果伤害
function c85520851.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
