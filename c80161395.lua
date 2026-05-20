--神秘の中華なべ
-- 效果：
-- 把自己场上1只怪兽作为祭品。选择祭品怪兽的攻击力或守备力，自己基本分回复那个数值。
function c80161395.initial_effect(c)
	-- 把自己场上1只怪兽作为祭品。选择祭品怪兽的攻击力或守备力，自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c80161395.cost)
	e1:SetTarget(c80161395.target)
	e1:SetOperation(c80161395.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选攻击力或守备力大于0，且属于自己场上（或自己场上表侧表示）的怪兽
function c80161395.filter(c,tp)
	return (c:GetAttack()>0 or c:GetDefense()>0) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价：解放自己场上1只怪兽，并选择该怪兽的攻击力或守备力数值记录在效果中
function c80161395.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c80161395.filter,1,nil,tp) end
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local sg=Duel.SelectReleaseGroup(tp,c80161395.filter,1,1,nil,tp)
	local tc=sg:GetFirst()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	-- 解放选择的怪兽作为发动代价
	Duel.Release(tc,REASON_COST)
	-- 提示玩家选择要回复的数值（攻击力或守备力）
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(80161395,0))  --"请选择要回复的数值"
	if atk>0 and def>0 then
		-- 若怪兽的攻击力和守备力都大于0，让玩家选择是根据“攻击力”还是“守备力”来回复
		if Duel.SelectOption(tp,aux.Stringid(80161395,1),aux.Stringid(80161395,2))==0 then  --"怪兽的攻击力/怪兽的守备力"
			e:SetLabel(atk)
		else
			e:SetLabel(def)
		end
	elseif atk>0 then
		-- 若只有攻击力大于0，则强制选择“攻击力”选项并记录该数值
		Duel.SelectOption(tp,aux.Stringid(80161395,1))  --"怪兽的攻击力"
		e:SetLabel(atk)
	else
		-- 若只有守备力大于0，则强制选择“守备力”选项并记录该数值
		Duel.SelectOption(tp,aux.Stringid(80161395,2))  --"怪兽的守备力"
		e:SetLabel(def)
	end
end
-- 效果的目标处理：设置回复对象为自己，回复数值为代价中记录的数值，并设置回复的操作信息
function c80161395.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为之前记录的攻击力或守备力数值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为“玩家回复记录的数值”
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 效果的处理：获取连锁信息中的目标玩家和回复数值，并执行回复基本分的操作
function c80161395.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和回复数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的基本分数值
	Duel.Recover(p,d,REASON_EFFECT)
end
