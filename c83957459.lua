--ライノタウルス
-- 效果：
-- 同1次的战斗阶段中，自己场上存在的怪兽的战斗把对方怪兽2只以上破坏的场合，这张卡在那次战斗阶段中可以作2次攻击。
function c83957459.initial_effect(c)
	-- 同1次的战斗阶段中，自己场上存在的怪兽的战斗把对方怪兽2只以上破坏的场合，这张卡在那次战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c83957459.macon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	if not c83957459.global_check then
		c83957459.global_check=true
		c83957459[0]=0
		c83957459[1]=0
		-- 自己场上存在的怪兽的战斗把对方怪兽……破坏的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(c83957459.checkop)
		-- 在全局注册一个用于监听怪兽被战斗破坏事件的系统效果，用以累计被破坏的怪兽数量
		Duel.RegisterEffect(ge1,0)
		-- 同1次的战斗阶段中
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c83957459.clear)
		-- 在全局注册一个在每个回合抽卡阶段开始时触发的系统效果，用以重置被战斗破坏的怪兽计数
		Duel.RegisterEffect(ge2,0)
	end
end
-- 累计被战斗破坏的怪兽数量，若被破坏的怪兽已不在场，则获取其原本控制者，并使该控制者的被破坏计数加1
function c83957459.checkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	local cp=bc:GetControler()
	if not bc:IsRelateToBattle() then cp=bc:GetPreviousControler() end
	c83957459[cp]=c83957459[cp]+1
end
-- 将双方玩家被战斗破坏的怪兽计数重置为0
function c83957459.clear(e,tp,eg,ep,ev,re,r,rp)
	c83957459[0]=0
	c83957459[1]=0
end
-- 判断当前玩家的对手被战斗破坏的怪兽数量是否达到2只以上，以此作为此卡可以进行2次攻击的条件
function c83957459.macon(e)
	return c83957459[e:GetHandlerPlayer()]>=2
end
