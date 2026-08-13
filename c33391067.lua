--呪詛返しのヒトガタ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：给与自己伤害的怪兽的效果发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
-- ②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己场上盖放。
function c33391067.initial_effect(c)
	-- ①：给与自己伤害的怪兽的效果发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c33391067.condition)
	e1:SetOperation(c33391067.refop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,33391067)
	e2:SetCondition(c33391067.setcon)
	e2:SetTarget(c33391067.settg)
	e2:SetOperation(c33391067.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：通过aux.damcon1确认己方将受到效果伤害（或回复转化为伤害），且触发效果来源是怪兽效果，二者同时满足才能发动。
function c33391067.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示：自己将受到来自效果（或反转成的伤害）的伤害，且该效果是怪兽卡的效果，即符合①的发动条件。
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果处理：记录当前造成伤害的怪兽效果的连锁ID，为控制者注册一个连锁结束前有效的伤害反射效果，使该效果对自己造成的效果伤害转由对方代为承受。
function c33391067.refop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被连锁的怪兽效果（即给与自己伤害的那个效果）的连锁ID，用于之后精确对应到该次效果造成的伤害。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- ①：那个效果发生的对自己的效果伤害由对方代受。②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己场上盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c33391067.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 把新建的伤害反射效果注册给玩家tp，使该反射效果在其整个持续期间（本连锁内）正常生效。
	Duel.RegisterEffect(e1,tp)
end
-- 反射判定函数：仅当处于连锁处理中、当前伤害原因包含效果伤害，且当前连锁ID与注册时记录的连锁ID一致时，才认定该伤害应被反射给对方。
function c33391067.refcon(e,re,val,r,rp,rc)
	-- 取得当前正在处理的连锁序号；若为0表示当前不在连锁处理中，不予反射。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 取得当前正在处理的效果（造成伤害的效果）的连锁ID，用于与记录的目标连锁ID比较。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
-- ②效果的发动条件：自己（tp）受到战斗伤害时满足，允许从墓地发动该效果。
function c33391067.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ②效果的发动目标合法检查：确认墓地的该卡能够盖放到场上；若满足则申报操作信息，表明将把这张卡从墓地移出并盖放。
function c33391067.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 申报本连锁的操作信息：对象为墓地里的这张卡1张，涉及“离开墓地”分类，便于其他卡（如王家长眠之谷）进行对应判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与该效果正常关联，则将其在自己场上里侧表示盖放。
function c33391067.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以里侧表示盖放到控制者tp的魔法与陷阱区域。
		Duel.SSet(tp,c)
	end
end
