--地母神アイリス
-- 效果：
-- 连锁积累有3个的场合，从自己卡组抽1张卡。同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
function c9628664.initial_effect(c)
	-- 同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c9628664.chop)
	c:RegisterEffect(e1)
	-- 连锁积累有3个的场合，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9628664,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c9628664.drcon)
	e2:SetTarget(c9628664.drtg)
	e2:SetOperation(c9628664.drop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 在每次有效果发动入连锁时，记录当前连锁数以及是否存在同名卡发动，并用Label标记状态
function c9628664.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号（即当前的连锁数）
	local ct=Duel.GetCurrentChain()
	if ct==1 then
		e:SetLabel(0)
	-- 检查当前连锁中是否存在同名卡的效果发动，若存在则不满足唯一性
	elseif not Duel.CheckChainUniqueness() then
		e:SetLabel(2)
	elseif ct>=3 and e:GetLabel()~=2 then
		e:SetLabel(1)
	end
end
-- 判断连锁结束时，之前记录的连锁状态是否满足“连锁数达到3个且没有同名卡发动”的条件，并重置标记
function c9628664.drcon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 设置抽卡效果的对象玩家为自己，参数为1张卡，并注册抽卡的操作信息
function c9628664.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前效果的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的对象参数设置为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，获取目标玩家和抽卡数量，让该玩家抽卡
function c9628664.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
